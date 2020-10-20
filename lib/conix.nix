x: with x; module ''
This module defines the user facing API for Conix.
''

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

  t = text;

  using = expr
      "(AttrSet -> Content) -> Content"
      [
        ''
        Creates expressions from functions that depend on the final `data`.
        Use this as follows:

        ''(n (data.code "nix" ''
        conix: with conix; <content expression here>
        ''))''

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

  tell = expr
      "AttrSet -> Content -> Content"
      "Add data to the given content. Attribute paths are absolute and not relative. _TODO: add an example_"
      (_data: _next: _tell { inherit _data _next; })
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
      (_fileName: data.file (x: pkgs.writeText "${_fileName}.md" x))
    ;

  pandoc = expr
      "FileExtension -> PandocCmdArgs -> BuildInputs -> FileName -> Content -> Content"
      "Construct a file using pandoc"
      (_pandocType: _pandocArgs: _buildInputs: _fileName:
       data.file
         (txt: pkgs.runCommand "${_fileName}.${_pandocType}" { buildInputs = [ pkgs.pandoc ] ++ _buildInputs; }
           ''
             ${pkgs.pandoc}/bin/pandoc -s -o $out ${_pandocArgs} ${pkgs.writeText "${_fileName}.md" txt}
           ''
         )
      )
    ;

  html = expr
      "FileName -> Content -> Content"
      "Construct an html file from the given content"
      (_fileName: data.pandoc "html" "" [] _fileName)
    ;

  pdf = expr
    "FileName -> Content -> Content"
      "Construct a PDF file from the given content"
      (_fileName: data.pandoc "pdf" "" [pkgs.texlive.combined.scheme-small] _fileName)
    ;

  meta = expr
      "[Content] -> Content" 
      "Construct the meta data portion of a Pandoc sytle markdown file"
      (_data: [ "---\n" ] ++ _data ++ [ "\n---\n" ])
    ;

  css = expr
      "FilePath -> Content"
      "When used with `meta` add the local css file to this html file's includes"
      (localPath: [ (data.local localPath) "css: ./${builtins.baseNameOf localPath}" ])
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
      (name: data.runCode "nix" (t: [ "\n" (data.code "" "${P.printNixVal (import (pkgs.writeText name t))}")] ))
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
      (s:
       builtins.foldl' 
         ({skip, as}: a:
           { skip = false;
             as = if skip then as ++ [a] else as ++ [s a];
           }
         )
         {skip=true; as = [];}
      )
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
}
