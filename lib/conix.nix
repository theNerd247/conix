conix: with conix;

let
  P = import ./printNixValue.nix pkgs;
in

module rec
{ 
  # TODO: add documentation about using Nix host language
  # to construct Content

  local = 
    [ "FilePath -> Content"
      "Add a local file to the generated derivation"
      _local
    ];

  text  =
    [ "Text -> Content"
      ''
      Append text to the current file.  
      ''
      _text
    ];

  t = text;

  using = 
    [ "(AttrSet -> Content) -> Content"
        ''
        Creates expressions from functions that depend on the final `data`.
        Use this as follows:

        ''
      #   (code "nix" ''
      #     conix: with conix; <conix expression here>
      #   '')''


      #   Here `conix = { pkgs = ...; data = ...; ... }` where `data` is the
      #   final `data` and the rest of the `conix` attribute set is the conix
      #   library and a copy of <nixpkgs> (in `pkgs` of course).
      # ''
      #]
      _using
    ];
      
  merge = 
    [
      "[Content] -> Content"
      ''
        Merge Contents together. This concatenates text values, collects files into a single directory,
        and recursively merges `data` values. 

        Normally when constructing text values and you wish to concatenate them together one wishes to
        use something like: `foo + "\n" + bar`. With `merge` one can simply write: `merge [ foo "\n" bar ]`
        and achieve the same affect.
      ''
      _merge
    ];

  
  file = 
    [ "(Text -> Derivation) -> Content -> Content"
      "Create a new file from the text produced by the given content"
      (_mkFile: _next: _file { inherit _mkFile; inherit _next; })
    ];

  tell = 
    [ "AttrSet -> Content -> Content"
      "Add data to the given content. Attribute paths are absolute and not relative. _TODO: add an example_"
      (_data: _next: _tell { inherit _data _next; })
    ];

  set = 
    [ "AttrSet -> Content"
      "Set a pure attribute set. This appends no new text to the content."
      (_data: data.tell _data (text ""))
    ];

  indent = _nSpaces: _next:
    _indent { inherit _nSpaces _next; };

  dir = _dirName: _next: 
    _dir { inherit _dirName _next; };

  markdown = _fileName: 
    data.file (builtins.toFile "${_fileName}.md");

 pandoc = _pandocType: _pandocArgs: _buildInputs: _fileName:
   data.file
     (txt: pkgs.runCommand "${_fileName}.${_pandocType}" { buildInputs = [ pkgs.pandoc ] ++ _buildInputs; }
       ''
         ${pkgs.pandoc}/bin/pandoc -s -o $out ${_pandocArgs} ${builtins.toFile "${_fileName}.md" txt}
       ''
     );

 html = _fileName: data.pandoc "html" "" [] _fileName;

 meta = _data: [ "---\n" ] ++ _data ++ [ "\n---\n" ];

 css = localPath: 
   [ (data.local localPath) "css: ./${builtins.baseNameOf localPath}" ];

 img = caption: localPath:
   [ (data.local localPath) "![${caption}](./${builtins.baseNameOf localPath})" ];

 list = builtins.map (content: [ "* " content "\n" ]); 

 code = lang: content:
   [ "```" data.lang "\n" data.content "\n```" ];

 runCode = lang: runner: content:
   [ (data.code data.lang content) (runner content) ];

 runNixSnippet = name: runCode "nix" 
   (t: [ "\n" (data.code "" "${P.printNixVal (import (builtins.toFile name t))}")] );

 table = headers: rows:
   [ (data.intersperse " | " headers) 
     "\n"
     (builtins.concatStringsSep " | " (builtins.map (_: "---") headers))
     "\n"
     (data.intersperse "\n" (builtins.map (intersperse " | ") rows))
   ];

 intersperse = s:
   builtins.foldl' 
     ({skip, as}: a:
       { skip = false;
         as = if skip then as ++ [a] else as ++ [s a];
       }
     )
     {skip=true; as = [];};

 dotgraph = name: dotCode:
   let
     graphvizCode = builtins.toFile "${name}.dot" dotCode;
   in
     [ (data.local (
         pkgs.runCommandLocal
           "${name}.svg" 
           { buildInputs = [ pkgs.graphviz ]; }
           "dot -Tsvg -o $out ${graphvizCode}"
       ))
       "![](./${name}.svg)"
     ];
}
