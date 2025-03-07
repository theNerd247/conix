internalLib: with internalLib; [

(_use (exprs.html "index" [

  (exprs.meta [
    (exprs.css exprs.conixCss)
    (exprs.pagetitle (_ask data.index.title))
  ])
 
 ''# ''{ index.title = ["Conix " exprs.conix.version.text]; }''
 
 ''{ intro = ''
 Conix is a Nix EDSL for technical writing. It brings the Nix
 programming language alongside markdown and implements an
 intuitive build system.
 
 ${if exprs.conix.version.major < 1
 then ''
   **Notice: This project is a work in progress. The API will be unstable
   until the first major release.**
 '' 
 else ""
 }
 '';}''
 
 # Documentation
 
 * [Github Repository](''(exprs.conix.git.url)'')
 * [API Reference Docs](''(_link refs.apiDocs)'')
 * [Getting Started](''(_link refs.gettingStarted)'')
 
 '']))


(module (docs: { apiDocs = _use (exprs.html "docs" [

  (exprs.meta [
    (exprs.css exprs.conixCss)
    (exprs.pagetitle (_ask data.apiDocs.title))
  ])''

  # ''{ apiDocs.title = "Conix API Docs"; }''


  ''
  docs
]);})

  ({ 
    # TODO: add documentation about using Nix host language
    # to construct Content
    evalExtended = expr
      "Content -> Content -> { text :: String, drv :: Derivation, data :: AttrSet, refs :: AttrSet, exprs :: AttrSet }"
      "Evaluate a Content with the conix library extended with the exprs defined in the first Content"
      (extensions: x: 
        let
          initApi = exprs // { inherit pkgs; };
          extendedApi = _eval initApi (liftNixValue extensions);
        in
          _eval (pkgs.lib.attrsets.recursiveUpdate extendedApi.exprs initApi) (liftNixValue x)
      )
      ;

    runExtended = expr
      "Content -> Content -> Derivation"
      "Runs evalExtended and extracts the derivation"
      (extensions: x: (exprs.evalExtended extensions x).drv)
      ;

    eval = expr
      "Content -> { text :: String, drv :: Derivation, data :: AttrSet, refs :: AttrSet, exprs :: AttrSet }"
      "Evaluate Content with just the conix library in scope"
      (exprs.evalExtended [])
      ;

    run = expr
      "Content -> Derivation"
      "Runs eval and extracts the derivation"
      (exprs.runExtended [])
      ;

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
      notice how we've defined `x` in two places. Nesting allows
      one to keep the first `x` from overriding the value of
      the second.
      ''
      (_path: _next: internalLib._nest { inherit _path _next; })
      ;

    ask = expr 
      "Content -> Content"
      [''
      Prevent infinite recursion when using a value from the data store as
      content.

      For example: 

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
      internalLib._ask
    ;

    r = expr
      "Content -> Content"
      "See `ref`"
      internalLib._ask;

    link = expr
      "Content -> Content"
      ''
      Generate a relative path to the given content

      For example:

      ```
      conix: with conix; [ (html "bob" { x = 3; }) (dir "larry" (html "joe" (link refs.x))) ]
      ```

      The content in `joe.html` will be a hyperlink pointing to `../bob.html`
      ''
      internalLib._link;

    using = expr
        "(AttrSet -> Content) -> Content"
        [
          ''
          Creates expressions from functions that depend on the final `data`.
          Use this as follows:

          ''(_use (exprs.code "nix" ''
          conix: with conix; <content expression here>
          ''))''

          Here `conix = { pkgs = ...; data = ...; ... }` where `data` is the
          final `data` and the rest of the `conix` attribute set is the conix
          library and a copy of <nixpkgs> (in `pkgs` of course).
          ''
        ]
        internalLib._using
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
        internalLib._merge
      ;

    
    file = expr
      "(Text -> Derivation) -> FileNameStr -> Content -> Content"
      "Create a new file from the text produced by the given content"
      (_mkFile: _fileName: _next: 
        _file { inherit _mkFile _next _fileName; }
      )
      ;

    tikzSvg = expr
        "FileName -> Content -> Content"
        "Take Tikz Code And Create An SVG image out of it. The image will be referenced. Tikz-cd is supported but there's no current way to extend the texlive environment."
        (_fileName: _content:
          # build tikz as a standalone pdf
          # take that pdf and call pdf2svg.
          [ (exprs.file
              (text: 
                  let
                    _tex = pkgs.writeText "${_fileName}.tex" 
                      ''
                      \documentclass[tikz, border=1mm]{standalone}
                      \usepackage{tikz-cd}
                      \usepackage{amsfonts}
                      \begin{document}
                      ${text}
                      \end{document}
                      '';

                    _pdf = pkgs.runCommandLocal
                      "${_fileName}.pdf"
                      {buildInputs = [ (pkgs.texlive.combine { inherit (pkgs.texlive) scheme-small amsfonts tikz-cd standalone; }) ]; }
                      "pdflatex ${_tex} &&  cp ./*.pdf $out";
                  in
                    pkgs.runCommandLocal  
                      "${_fileName}.svg"
                      {buildInputs = [pkgs.pdf2svg];}
                      "pdf2svg ${_pdf} $out"
              )
              _fileName
              _content
            )
            "![](./${_fileName}.svg){width=100%}"
          ]
        );
    
    pandoc = expr
      "OutputFileExtension -> PandocCmdArgs -> BuildInputs -> FileName -> Content -> Content"
      "Use pandoc to construct a file from the given content"
      (_pandocType: _pandocArgs: _buildInputs: _fName:
        let
          _fileName = "${_fName}.${_pandocType}";
          _mkFile = txt: 
            pkgs.runCommand _fileName { buildInputs = [ pkgs.pandoc ] ++ _buildInputs; }
            ''
            ${pkgs.pandoc}/bin/pandoc -s -o $out ${_pandocArgs} ${pkgs.writeText "${_fName}.md" txt}
            '';
        in
          exprs.file _mkFile _fileName
      );

    html = expr
      "FileName -> Content -> Content"
      "Create an HTML file from the given content"
      (exprs.pandoc "html" "" []);

    pdf = expr
      "FileName -> Content -> Content"
      "Create a PDF file from the given content"
      (exprs.pandoc "pdf" "" [pkgs.texlive.combined.scheme-small]);

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

    modtxt = expr
      "(Text -> Text) -> Content -> Content"
      "Modify the text produced by the content"
      (_modify: _next: internalLib._modtxt { inherit _modify _next; })
      ;

    indent = expr
        "Natural -> Content -> Content"
        "Indent the text of the content by the given number of spaces"
        (nSpaces: exprs.modtxt ((import ./textBlock.nix pkgs).indent nSpaces))
      ;

    dir = expr
        "DirName -> Content -> Content" 
        "Nest the file heirarchy of the given content into the given directory"
        (_dirName: _next: _dir { inherit _dirName _next; })
      ;

    markdown = expr
        "FileName -> Content -> Content" 
        "Create a markdown file from the given text" 
        (_fName: exprs.textfile "${_fName}.md")
      ;

    textfile = expr
        "FileName -> Content -> Content" 
        "Write the content to the given text file" 
        (fName: exprs.file (pkgs.writeText fName) fName) 
      ;

    meta = expr
      "[Content] -> Content" 
      "Construct the meta data portion of a Pandoc sytle markdown file"
      (x: [ "\n\n---\n" (exprs.intersperse "\n" x) "\n---\n\n" ])
      ;

    css = expr
      "FilePath -> Content"
      ''
      When used with `meta` add the local css file to this html file's
      includes
      ''
      (localPath: [ "css: " (exprs.pathOf localPath) ])
      ;

    pagetitle = expr
        "String -> Content"
        "The title of the rendered document"
        (title: [ ["pagetitle: " title]"\n" ["title: " title] ])
        ;

    pathOf = expr
      "LocalFilePath -> Content"
      ''
      Writes the given file path as text and includes the referenced file in the
      output
      ''
      (localPath:
        [ 
          (exprs.local localPath)
          "./${builtins.baseNameOf localPath}"
        ]
      )
      ;

    img = expr
        "CaptionText -> FilePath -> Content"
        "Inserts an image in the given document and ensures that the imported image exits and is included in the final derivation"
        (caption: localPath:
          [ "![${caption}](" (exprs.pathOf localPath) ]
        )
      ;

    list = expr
        "[Content] -> Content" 
        "Create a bullet list"
        (builtins.map (content: [ "\n* " content ]))
      ; 

    code = expr
        "Language -> Code -> Content"
        "Create a markdown code block"
        (lang: content: [ "\n\n```" lang "\n" content "\n```" ])
      ;

    runCode = expr
        "Language -> (Content -> Content) -> Code -> Content"
        "Create a code block and append the results of executing the passed runner"
        (lang: runner: content:
          [ (exprs.code lang content) (runner content) ]
        )
      ;

    runNixSnippet = expr
        "SnippetName -> NixCode -> Content" 
        "Create a Nix code block, execute the code, and append the results as a second code block"
        (name: exprs.runCode "nix" 
          (t: 
            [ "\n" 
              (exprs.code "" 
                (exprs.printNixVal (import (pkgs.writeText name t)))
              )
            ]
          )
        )
        ;

    runConixSnippet = expr
      "SnippetName -> Content -> Content"
      "Run the given Conix code and insert its resulting text"
      (name: exprs.modtxt 
        (t: "${(exprs.eval (import (pkgs.writeText name "conix: with conix; ${t}"))).text}")
      )
      ;

    tutorialSnippet = expr
      "FileName -> AttrPathName -> Content -> Content"
      "Create a nix snippet with its content under a reference"
      (fileName: refName: content:
        [ 
          ''```nix
          ''{ tutorials.${refName} = exprs.textfile fileName content; }''
          
          ```
          ''
        ]
      )
    ;

    jsSnippet = expr
      "FileName -> Content -> Content"
      "Display javascript code, run its result - using node, and display the result"
      (fileName:
        exprs.modtxt (t:
          ''```javascript
          ${t}
          ```
          evaluates to
          ```
          ${builtins.readFile (pkgs.runCommand "${fileName}-out" {buildInputs = [pkgs.nodejs_23]; } "node ${pkgs.writeText "${fileName}.js" t} > $out")}
          ```
          ''
        )
      );

    table = expr
        "[Content] -> [[Content]] -> Content" 
        "Create a markdown table with the given headers and rows"
        (headers: rows:
        [ 
          "\n"
          (exprs.intersperse " | " headers) 
          "\n"
          (builtins.concatStringsSep " | " (builtins.map (_: "---") headers))
          "\n"
          (exprs.intersperse "\n" (builtins.map (exprs.intersperse " | ") rows))
        ])
      ;

    intersperse = expr
        "a -> [a] -> [a]"
        "Insert the given element inbetween elements of the given list"
        (s: xs:
          (builtins.foldl' 
            ({skip, as}: a:
              { 
                skip = false;
                as = if skip then as ++ [a] else as ++ [s a];
              }
            )
            {skip=true; as = [];}
            xs
          ).as
        )
      ;

    dotgraph = expr
        "ImageName -> DOTCode -> Content"
        "Create an graph image from the given DOT code"
        (name: dotCode:
          let
            graphvizCode = pkgs.writeText "${name}.dot" dotCode;
          in
            [ (exprs.local (
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
      (imgName: code: exprs.dotgraph imgName "digraph { ${code} }")
      ;


    conix =
      let
        meta = import ./meta.nix;
      in
      {
        homepageUrl = expr
          "URLString"
          "The homepage URL of conix"
          meta.homepageUrl;

        git = 
        {
          url = expr
            "URLString"
            "The HTTP URL of the conix GIT repo"
            meta.git.url;

          rev = expr
            "GitCommitHashString"
            "The GIT commit hash of conix repo currently used"
            "<rev>";

          ref = expr
            "GitBranchString"
            "The GIT branch of the conix repo currently being used"
            "<ref>";

          text = expr
            "NixString"
            "String containing a Nix Attribute expression representing `conix.git`"
            (exprs.printNixVal meta.git);
        };

        version =
        { 
          text = expr
            "SemanticVersionString"
            ''
            The semantic version of the conix repo being used.

            It is formatted as: `major.minor.patch`
            ''
            meta.version.text;

          major = expr
            "Natural"
            "The major version of the conix repo being used"
            meta.version.major;

          minor = expr
            "Natural"
            "The minor version of the conix repo being used"
            meta.version.minor;

          patch = expr
            "Natural"
            "The patch version of the conix repo being used"
            meta.version.patch;
        };
      };

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

    conixCss = expr
      "FileName -> Content -> Content"
      ''
      The css file conix uses for generating its documentation
      ''
      ../static/latex.css
      ;

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
  } // (import ./printNixValue.nix internalLib))
)


]
