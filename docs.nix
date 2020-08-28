conix: { lib = rec
{
  mkDocModule = doc: path: 
    let p = builtins.concatStringsSep "." path; in
    if ! builtins.isAttrs doc then conix.lib.emptyModule else
    conix.lib.texts [ 
      ''
      <hr/>
      ''
      (doc.docstr or conix.lib.emptyModule)
      ( if doc ? todo 
        then conix.lib.texts 
          [ "_Todo_\n\n" (conix.lib.md.list "todo" doc.todo) ]
        else conix.lib.emptyModule
      )
      ''

      ```haskell
      ${p} :: ${doc.type or (throw "missing docs.${p}.type assignment")}
      ```
      ''
    ];

  collectDocModules = conix.lib.foldAttrsIxCond 
    (s: s ? type)
    mkDocModule
    (moduleMap: conix.lib.foldModules (builtins.attrValues moduleMap));

  docs.mkDocs.docstr = conix.lib.texts [''
    Creates a module containing markdown documentation of an nested attribute set
    where the leaves are docs.

    A doc is:

    ```
    Doc = ''(conix.lib.label "docType" "{ docstr : String; type = String; todo = [ String ]; }")''
    ```

    Conix uses this to produce its own reference documentation by setting the
    `conix.lib.docs` attribute set in its pages and then creates an html
    derivation by calling this function and passing the resulting module to
    `htmlFile` and `markdownFile`.  
  ''];
  docs.mkDocs.type = "AttrSet -> Module";
  mkDocs = docsAttrSet:
      collectDocModules (builtins.removeAttrs docsAttrSet ["text" "drv"]);

  referenceDocumentation = with conix.lib; using [(markdownFile "docs") (htmlFile "docs" "--metadata pagetitle=docs --css ./static/latex.css")] (texts [
      ''
      # Reference Documentation - ${conix.lib.version.text}

      ''
      (mkDocs conix.lib.docs)
      ''
      ## Discussion

      ### Modules
      
      Modules are the core of conix. Their type is defined as:
     
      ```haskell
      type Module = ''(label "moduleType" "{ text :: String, drvs :: [Derivation], ... }")''

      ```


      `text`
      : the final authored content that the module produces. If a module is used
      to create say, a markdown file, then this is the contents of that file.
      When two modules are merged (see `mergeModules`) there text values are
      concatenated (left to right).

      `drvs`
      : this is the list of derivations that may be produced along side some
      content. Normally modules would either contain only text or only
      derivations alongside the user's data. Example derivations in this list
      would be a list of files that the given texts produces (markdown, html,
      etc.)

      `...`
      : These are user defined attribute key/values that store custom data
      required to build the text value.
     
      An example module looks like:

      ```nix 
      ''(label "sampleModule" 
      ''
      (rec 
      { drvs = [ (conix.pkgs.writeText "foo.md" text) ];
        welcomeMessage = "I <3 F-algebras"; 
        text = '''
          # Hello World

          ''${welcomeMessage}
        ''';
      })
      '')''
      ```

      And here is that module evaluated:
     
      ''(runSnippet "sampleModuleBuild" "nix"
      ''
      (import <nixpkgs> { 
        overlays = import (builtins.fetchGit
          ${indent 4 conix.lib.git.text}
        );
      }).conix.eval 
      (conix: { sample = 
        ${indent 2 conix.lib.referenceDocumentation.sampleModule}
      ;})
      ''
      (fp: "${printNixVal (import fp)}")
      )''

      #### Why Is Drvs a List?

      The `drvs` field is the free monoid over (aka: list of) derivations. I made
      this decision out of pure laziness; defering what it means to merge
      derivations until the user tells me so. Right now the library only provides
      `dir` and `collect` for creating derivations that merge other derivations.

      ### Pages

      A Page is just a function from what's called "the final module" to a
      portion of the final module. Here's a Page's type:

        ```haskell
        type Page = Module -> Module
        ```
      and an example of a page:

      ```nix
      ''(label "samplePage" ''(conix: { sample = { text = "foo"; drvs = []; x = 3; }; })'')''

      ```
      And here is that page when evaluated:
      
      ''(runSnippet "samplePageBuild" "nix"
      ''
      (import <nixpkgs> { 
        overlays = import (builtins.fetchGit
          ${indent 4 conix.lib.git.text}
        );
      }).conix.eval 
      ${conix.lib.referenceDocumentation.samplePage}
      ''
      (fp: "${printNixVal (import fp)}")
      )''

      The eval function is used to convert a page into the final module. This
      final module is what gets passed as the `conix` argument for each page.
      By giving each page access to the final module set one is able to create
      multiple pages where each module returned by a page is only a small
      subset of the final module.

      Another example:

      ```nix
      ''(label "samplePage2" 
      ''
      [(conix: { sample = { text = "foo"; drvs = []; x = 3; }; })
       (conix: { sample.y = conix.sample.x + 5; sample2 = { text = "bar"; drvs = []; y = 4; }; })
      ]
      '')''

      ```
      And here is that page when evaluated:
      
      ''(runSnippet "samplePageBuild" "nix"
      ''
      (import <nixpkgs> { 
        overlays = import (builtins.fetchGit
          ${indent 4 conix.lib.git.text}
        );
      }).conix.evalPages
      ${conix.lib.referenceDocumentation.samplePage2}
      ''
      (fp: "${printNixVal (import fp)}")
      )''

      You'll notice that `sample` has `x` defined in the first page and `y`
      defined in the second. But in the final module `sample` contains both `x`
      and `y` attributes. Even more, the `y` value is computed by using the
      `sample.x` value from the final module. This is what gives conix its
      power, users can reference arbitrary data from the final module to create
      new modules. This means content can be created by re-using content from
      other pieces of content.

      Also, you'll notice that `sample2` defines another toplevel module with
      its own data. When evaluating multiple pages conix simply recursively
      merges each module together.

      ### Infinite Recursion

      Internally conix is using the `fix` function[^1].

      [^1]: For those who don't know what the `fix` function is:

            ```haskell
            fix :: (a -> a) -> a
            fix f = let x = f x in x
            -- which expands to: fix f = f (fix (f (fix (f ...))))
            ```
          Also you might want to read up on it. [Fixed Point](https://en.wikipedia.org/wiki/Fixed-point_combinator).

      Because of this one can run into infinite recursion issues if they are
      not careful. Particularly, if one defines data in a module and then tries
      to consume that data; depending on how that data is used you might get an
      infinite recursion error. To avoid this simply use the `t` function (see
      the documentation above).
      
      ---
      Built using ${conix.lib.homePageLink} version ${conix.lib.version.text}
      ''
    ]);
};}
