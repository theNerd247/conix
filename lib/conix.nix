internalLib: with internalLib; [ 

(markdown "readme" (htmlModule "index" [

''
# Conix ''(conix.version.text)''

Conix is a Nix EDSL for technical writing. It brings the Nix
programming language alongside markdown and implements an
intuitive build system.

${if conix.version.major < 1
then ''
**Notice: This project is a work in progress and the API will have major
updates pushed to the master branch until the first major release.**
'' 
else ""
}

# Documentation

* [API Reference Docs](./docs.html)

# Contributing

Any ideas or help are welcome! Please submit a PR or open an issue as you see
fit. I like to use the project board to organize my thoughts; check the todo
column for tasks to work on. I will try and convert these to issues when I can.

# Related Works

* [Pollen](https://docs.racket-lang.org/pollen/) - _"Pollen is a publishing
system that helps authors make functional and beautiful digital books."_

# Acknowledgements

Many thanks to:

  * [Gabriel Gonzalez](https://github.com/Gabriel439) for his mentorship and guidance. 
  * [Evan Relf](https://github.com/evanrelf) for his insightful feedback.
  * [Paul Young](https://github.com/paulyoung) for great feedback and ideas.
''

]))

(htmlModule "docs" [(module "## Conix API\n\n"

rec
{ 
  # TODO: add documentation about using Nix host language
  # to construct Content

  local = expr
      "FilePath -> Content"
      "Add a local file to the generated derivation"
      _local
    ;

  text  = expr
      "Text -> Content"
      "Append text to the current file."
      _text
    ;

  nest = expr
    "PathString -> Content -> Content"
    ''
    Nest the data for the given content under a given path

    For example:

    ```nix
      m: with m;
      [
        (nest "foo.bar" (n: with n; [{ x = 3; } (r data.x)]))
        {x = 4;}

        (r data.x)
      ]
    will produce:

    ```nix
    "3344"
    ```
    notice how we've defined `x` in two places.
    ```
    ''
    (_path: _next: internalLib._nest { inherit _path _next; })
    ;

  t = text;

  ref = expr 
    "Content -> Content"
    [''
    Prevent infinite recursion when using a value from the data store as
    content.

    For example: 

    ''(internalLib.ref (data.code "nix" ''
    [ { x = 3; }
      data.x
    ]
    ''))''

    Will break with an `infinite recursion` error. To resolve this do:

    ```nix
    [ { x = 3; }
      (ref data.x)
    ]
    ```
    or (if you don't like typing "ref"):

    ```nix
    [ { x = 3; }
      (r data.x)
    ]
    ```
    '']
    internalLib.ref
  ;

  r = expr
    (internalLib.ref data._docs.ref.type)
    "See `ref`"
    internalLib.ref;

  using = expr
      "(AttrSet -> Content) -> Content"
      [
        ''
        Creates expressions from functions that depend on the final `data`.
        Use this as follows:

        ```nix
        conix: with conix; <content expression here>
        ```

        Here `conix = { pkgs = ...; data = ...; ... }` where `data` is the
        final `data` and the rest of the `conix` attribute set is the conix
        library and a copy of <nixpkgs> (in `pkgs` of course).
        ''
      ]
      _using
    ;
      
  merge = expr
     
      "[Content] -> Content"
      ''
        Merge Contents together. This concatenates text values, collects files into a single directory,
        and recursively merges `data` values. 

        Normally when constructing text values and you wish to concatenate them together one wishes to
        use something like: `foo + "\n" + bar`. With `merge` one can simply write: `merge [ foo "\n" bar ]`
        and achieve the same affect.
      ''
      _merge
    ;

  
  file = expr
      "(Text -> Derivation) -> Content -> Content"
      "Create a new file from the text produced by the given content"
      (_mkFile: _next: _file { inherit _mkFile; inherit _next; })
    ;

  pandoc = expr
    "OutputFileExtension -> PandocCmdArgs -> BuildInputs -> FileName -> Content -> Content"
    "Use pandoc to construct a file from the given content"
    internalLib.pandoc;

  html = expr
    "FileName -> Content -> Content"
    "Create an HTML file from the given content"
    internalLib.html;

  pdf = expr
    "FileName -> Content -> Content"
    "Create a PDF file from the given content"
    internalLib.pdf;

  tell = expr
      "AttrSet -> Content -> Content"
      "Add data to the given content. Attribute paths are absolute and not relative. _TODO: add an example_"
      internalLib._tell
    ;

  set = expr
      "AttrSet -> Content"
      "Set a pure attribute set. This appends no new text to the content."
      (_data: _tell { inherit _data; _next = _text ""; })
    ;

  indent = expr
      "Natural -> Content -> Content"
      "Indent the text of the content by the given number of spaces"
      (_nSpaces: _next: _indent { inherit _nSpaces _next; })
    ;

  dir = expr
      "DirName -> Content -> Content" 
      "Nest the file heirarchy of the given content into the given directory"
      (_dirName: _next: _dir { inherit _dirName _next; })
    ;

  markdown = expr
      "FileName -> Content -> Content" 
      "Create a markdown file from the given text" 
      internalLib.markdown
    ;

  meta = expr
      "[Content] -> Content" 
      "Construct the meta data portion of a Pandoc sytle markdown file"
      internalLib.meta
    ;

  css = expr
      "FilePath -> Content"
      ''
      When used with `meta` add the local css file to this html file's
      includes
      ''
      internalLib.css
    ;

  pathOf = expr
    "LocalFilePath -> Content"
    ''
    Writes the given file path as text and includes the referenced file in the
    output
    ''
    internalLib.pathOf
    ;

  img = expr
      "FilePath -> Content"
      "Inserts an image in the given document and ensures that the imported image exits and is included in the final derivation"
      (caption: localPath:
       [ (data.local localPath) "![${caption}](./${builtins.baseNameOf localPath})" ]
      )
    ;

  list = expr
      "[Content] -> Content" 
      "Create a bullet list"
      (builtins.map (content: [ "* " content "\n" ]))
    ; 

  code = expr
      "Language -> Code -> Content"
      "Create a markdown code block"
      (lang: content: [ "```" lang "\n" content "\n```" ])
    ;

  runCode = expr
      "(Content -> Content) -> Language -> Code -> Content"
      "Create a code block and append the results of executing the passed runner"
      (lang: runner: content:
       [ (data.code lang content) (runner content) ]
      )
    ;

  runNixSnippet = expr
      "SnippetName -> NixCode -> Content" 
      "Create a Nix code block, execute the code, and append the results as a second code block"
      (name: data.runCode "nix" 
      (t: 
        [ "\n" 
          (data.code "" 
            (data.printNixVal (import (pkgs.writeText name t)))
          )
        ] 
      ))
      ;

  table = expr
      "[Content] -> [[Content]] -> Content" 
      "Create a markdown table with the given headers and rows"
      (headers: rows:
       [ (data.intersperse " | " headers) 
         "\n"
         (builtins.concatStringsSep " | " (builtins.map (_: "---") headers))
         "\n"
         (data.intersperse "\n" (builtins.map (data.intersperse " | ") rows))
      ])
    ;

  intersperse = expr
      "a -> [a] -> [a]"
      "Insert the given element inbetween elements of the given list"
      internalLib.intersperse
    ;

  dotgraph = expr
      "ImageName -> DOTCode -> Content"
      "Create an graph image from the given DOT code"
      (name: dotCode:
        let
          graphvizCode = pkgs.writeText "${name}.dot" dotCode;
        in
          [ (data.local (
              pkgs.runCommandLocal
                "${name}.svg" 
                { buildInputs = [ pkgs.graphviz ]; }
                "dot -Tsvg -o $out ${graphvizCode}"
            ))
            "![](./${name}.svg)"
          ]
      )
    ;

  
  digraph = expr
    "ImageName -> DOTCode -> Content"
    "Shorthand for: `dotgraph imgName \"digraph { ... }\"`"
    (imgName: code: data.dotgraph imgName "digraph { ${code} }")
    ;
  })

  (import ./printNixValue.nix)

  (module ''
    ### Conix Meta Data API

    Use the following functions to use meta data on the conix repo in your content
    ''
    { conix =
      {
        homepageUrl = expr
          "URLString"
          "The homepage URL of conix"
          internalLib.conix.homepageUrl;

        git = 
        {
          url = expr
            "URLString"
            "The HTTP URL of the conix GIT repo"
            internalLib.conix.git.url;

          rev = expr
            "GitCommitHashString"
            "The GIT commit hash of conix repo currently used"
            internalLib.conix.git.rev;

          ref = expr
            "GitBranchString"
            "The GIT branch of the conix repo currently being used"
            internalLib.conix.git.ref;
        };

        version =
        { 
          text = expr
            "SemanticVersionString"
            ''
            The semantic version of the conix repo being used.

            It is formatted as: `major.minor.patch`
            ''
            internalLib.conix.version.text;

          major = expr
            "Natural"
            "The major version of the conix repo being used"
            internalLib.conix.version.major;

          minor = expr
            "Natural"
            "The minor version of the conix repo being used"
            internalLib.conix.version.minor;

          patch = expr
            "Natural"
            "The patch version of the conix repo being used"
            internalLib.conix.version.patch;
        };
      };
    }
  )

  (module ''
    ### Conix Module API

    The following functions are available for constructing modules:
    conix expressions that extend the conix core library as well as
    generate documentation.
    ''
    { 
      module = expr
        "Content -> { Path :: Expression } -> Content"
        ''
        Create a new module with the given module doc string and
        attribute set containing expressions. 

        The first argument is content (typically module level documentation) to
        insert _before_ API documentation.

        For example: 
        
        ```nix
          module 
            '''
            # String API

            This is an api for creating fancy strings.
            '''
            { 
              appendPeriod = expr
                "Content -> Content"
                "Appends a period to the given content"
                (x: [ x "."])
                ;
            }
        ```
        ''
        internalLib.module;

      expr = internalLib.expr
        "HaskellTypeString -> Content -> a"
        ''
        Create a new API expression with a type, documentation, and a Nix value.

        Traditionally Nix modules are just attribute sets with their values being
        API expressions (e.g a function). Documentation is left as comments and
        types don't exist. `expr` abstracts over documentation, types, and the
        user defined function to make documentation first class in Nix.
        ''
        internalLib.expr
        ;

      htmlModule = expr
        "FileName -> Content -> Content"
        ''
        Create an html file that is styled just like the conix core API.

        This is provided as a convenience function. Feel free to use the normal
        API to generate custom API formats. For example you may want a PDF
        version of your API docs:

        ```nix
        pdf "myDocs" 
          (module "# MY API Docs\n\n"
          { 
            addOne = expr
              "Natural -> Natural"
              "adds one..."
              (x: x+1)
              ;
          }
        ```
        ''
        internalLib.htmlModule
        ;
    }
  )

  (module ''
    ### Utility API

    ''
    { 
      foldAttrsIxCond = expr
        F.docs.foldAttrsIxCond.type 
        F.docs.foldAttrsIxCond.docstr
        internalLib.foldAttrsIxCond
        ;

      foldAttrsCond = expr
        F.docs.foldAttrsCond.type
        F.docs.foldAttrsCond.docstr
        internalLib.foldAttrsCond
        ;

      foldlIx = expr
        F.docs.foldlIx.type
        "Left fold with index"
        internalLib.foldlIx
        ;
    }
  )

])

]
