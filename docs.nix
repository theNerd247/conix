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

  referenceDocumentation = with conix.lib; using [(markdownFile "docs") (htmlFile "docs" "--metadata title=docs")] (texts [
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

      ```nix ''(label "sampleModule" 
      ''
      (rec 
      { drvs = [ ];
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
      ${conix.lib.referenceDocumentation.sampleModule}
      ''
      (fp: "${conix.lib.printNixVal (import fp)}")
      )''

      #### Why Is Drvs a List?

      The `drvs` field is the free monoid over (aka: list of) derivations. I made
      this decision out of pure laziness; defering what it means to merge
      derivations until the user tells me so. Right now the library only provides
      `dir` and `collect` for creating derivations that merge other derivations.

      ### Pages

      A Page is just a function from the final module to a portion of the final
      module. Here's its type:

        ```haskell
        type Page = Module -> Module
        ```
      Here's an example:

      ```nix
      ''(label "samplePage" ''(conix: { sample = { text = "foo"; drvs = []; x = 3; }; })'')''
      ```
      And here is that page when built:
      
      ''(runSnippet "samplePageBuild" "nix"
      ''
      (import <nixpkgs> { 
        overlays = import (builtins.fetchGit
          ${indent 4 conix.lib.git.text}
        );
      }).conix.eval 
      ${conix.lib.referenceDocumentation.samplePage}
      ''
      (fp: "${builtins.readFile (import fp)}")
      )''

      The eval function is used to convert a page into a list of pages.

      ### Infinite Recursion
      
      ---
      Built using ${conix.lib.homePageLink} version ${conix.lib.version.text}
      ''
    ]);
};}
