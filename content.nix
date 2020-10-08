pkgs:

let
  T = import ./types.nix;
  F = import ./foldAttr.nix pkgs;
in

# Re-export constructors to build the toplevel api
rec
{ 
  # Main API
  local = _local;
  text  = _text;
  using = _using;
  merge = _merge;

  t = text;

  # "Parses" nix values into Content values
  # using mutual recursion
  # a -> Content
  liftNixValue = t: fmap liftNixValue (
         if T.isTyped t           then t 
    else if builtins.isPath t     then local t
    else if builtins.isAttrs t    then tell t (collectTexts t)
    else if builtins.isFunction t then using t
    else if builtins.isList t     then merge t
    else text t
  );

  renderTypeFileName = x: x._val._fileName;

  collectTexts = F.foldAttrsCond
    T.isTyped
    liftNixValue
    (vals: merge (builtins.attrValues vals));

  docs.content.file.type = "RenderType -> Content -> Content";
  file = _mkFile: _next: _file 
    { inherit _mkFile; 
      inherit _next; 
    };

  docs.content.tell.type = "AttrSet -> Content -> Content";
  tell = _data: _next: _tell { inherit _data _next; };

  docs.content.set.type = "AttrSet -> Content";
  set = _data: _tell { inherit _data; _next = text ""; };

  dir = _dirName: _next: 
    _dir { inherit _dirName _next; };

  markdown = _fileName: 
    file (builtins.toFile "${_fileName}.md");

  pandoc = _pandocType: _pandocArgs: _buildInputs: _fileName:
    file
      (txt: pkgs.runCommand "${_fileName}.${_pandocType}" { buildInputs = [ pkgs.pandoc ] ++ _buildInputs; }
        ''
          ${pkgs.pandoc}/bin/pandoc -s -o $out ${_pandocArgs} ${builtins.toFile "${_fileName}.md" txt}
        ''
      );

  html = pandoc "html" "" [];

  meta = data: [ "---\n" ] ++ data ++ [ "\n---\n" ];

  css = localPath: 
    [ (local localPath) "css: ./${builtins.baseNameOf localPath}" ];

  img = caption: localPath:
    [ (local localPath) "![${caption}](./${builtins.baseNameOf localPath})" ];

  code = lang: content:
    [ "```" lang "\n" content "\n```" ];

  runCode = lang: runner: content:
    [ (code lang content) (runner content) ];

  runNixSnippet = name: runCode "nix" 
    (t: [ "\n" (code "" "${builtins.readFile (import (builtins.toFile name t))}")] );

  table = headers: rows:
    [ (intersperse " | " headers) 
      "\n"
      (builtins.concatStringsSep " | " (builtins.map (_: "---") headers))
      "\n"
      (intersperse "\n" (builtins.map (intersperse " | ") rows))
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
      [ (local (
          pkgs.runCommandLocal
            "${name}.svg" 
            { buildInputs = [ pkgs.graphviz ]; }
            "dot -Tsvg -o $out ${graphvizCode}"
        ))
        "![](./${name}.svg)"
      ];

  # Internals

  # Markup Constructors
  docs.content._tell.type = "{ _data :: AttrSet, _next :: a} -> ContentF a";
  _tell = T.typed "tell";

  docs.content._using.type = "(AttrSet -> a) -> ContentF a";
  _using = T.typed "using";

  # NOTE: for now we'll use the final encoding of documents. However,
  # In the future it might be useful to use the inital encoding
  # (like a copy of the Pandoc AST).
  docs.content.text.type = "String -> ContentF a";
  _text = T.typed "text";

  # File System Constructors
  docs.content._file.type = "{_fileName :: FileName, _next :: a} -> ContentF a";
  _file = T.typed "file";

  docs.content._dir.type = "{ _dirName :: DirName, _next :: a} -> ContentF a";
  _dir = T.typed "dir";

  docs.content._local.type = "FilePath -> ContentF a";
  _local = T.typed "local";

  docs.content._merge.type = "[a] -> ContentF a";
  _merge = T.typed "merge";

  fmapMatch = f:
    { 
      "tell"  = {_data, _next}: _tell { inherit _data; _next = f _next; };
      "text"  = x: _text x;
      "local" = x: _local x;
      "file"  = {_mkFile, _next}: 
        _file { inherit _mkFile; _next = f _next; };
      "dir" = {_dirName, _next}:
        _dir { inherit _dirName; _next = f _next; };
      "merge" = xs: _merge (builtins.map f xs);
      "using" = g: _using (x: f (g x));
    };

  fmap = T.matchWith fmapMatch;
}
