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
  file = _renderType: _next: _file 
    { inherit _renderType; 
      inherit _next; 
    };

  docs.content.tell.type = "AttrSet -> Content -> Content";
  tell = _data: _next: _tell { inherit _data _next; };

  docs.content.set.type = "AttrSet -> Content";
  set = _data: _tell { inherit _data; _next = text ""; };

  dir = _fileName: 
    file (_dir { inherit _fileName; });

  markdown = _fileName:
    file (_markdown { inherit _fileName; });

  pandoc = _pandocType: _pandocArgs: _buildInputs: _fileName:
    file (_pandoc { inherit _fileName _pandocType _pandocArgs _buildInputs; });

  html = pandoc "html" "" [];

  meta = data: [ "---\n" ] ++ data ++ [ "\n---\n" ];

  css = localPath: 
    [ (local localPath) "css: ./${builtins.baseNameOf localPath}" ];

  img = caption: localPath:
    [ (local localPath) "![${caption}](./${builtins.baseNameOf localPath})" ];

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
  docs.content._file.type = "{_renderType :: RenderType, _next :: a} -> ContentF a";
  _file = T.typed "file";

  docs.content._local.type = "FilePath -> ContentF a";
  _local = T.typed "local";

  # Render Type Constructors
  docs.content._pandoc.type = "{ _fileName :: FileName, _pandocType :: String, _pandocArgs :: String, _buildInputs :: [Derivation] } -> RenderType";
  _pandoc = T.typed "pandoc";

  docs.content._markdown.type = "{_fileName :: FileName} -> RenderType";
  _markdown = T.typed "markdown";

  docs.content._html.type = "{_fileName :: FileName, _cssFiles :: [ Derivation ], _jsFiles :: [ Derivation ] }";
  _html = T.typed "html";

  docs.content._dir.type = "DirName -> RenderType";
  _dir = T.typed "dir";

  docs.content._merge.type = "[a] -> ContentF a";
  _merge = T.typed "merge";

  fmapMatch = f:
    { 
      "tell"  = {_data, _next}: _tell { inherit _data; _next = f _next; };
      "text"  = x: _text x;
      "local" = x: _local x;
      "file"  = {_renderType, _next}: 
        _file { inherit _renderType; _next = f _next; };
      "merge" = xs: _merge (builtins.map f xs);
      "using" = g: _using (x: f (g x));
    };

  fmap = T.matchWith fmapMatch;
}
