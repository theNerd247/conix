let
  T = import ./types.nix;
in

# Re-export constructors to build the toplevel api
rec
{ 
  # Main API
  local    = _local;
  text     = _text;

  t = text;

  liftText = t: 
    if builtins.isString t then text t 
    else if builtins.isAttrs t && ! t ? _type then _tell { _data = t; _next = text ""; }
    else t;

  renderTypeFileName = x: x._val._fileName;

  dir = _dirName: _next: _dir { inherit _dirName _next; };

  docs.content.file.type = "RenderType -> [Content] -> Content";
  file = _renderType: _next: 
    _file { inherit _renderType; _next = dir (renderTypeFileName _renderType) _next; };

  docs.content.tell.type = "AttrSet -> Content -> Content";
  tell = _data: _next: _tell { inherit _data _next; };

  docs.content.set.type = "AttrSet -> Content";
  set = _data: tell _data (text "");

  markdown = _fileName:
    file (_markdown { inherit _fileName; });

  pandoc = _fileName: _pandocType: _pandocArgs: 
    file (_pandoc { inherit _fileName _pandocType _pandocArgs; });

  # Internals
  #
  # TODO: if this grows large move to its own module
  # right now I'm lazy....

  docs.content._merge.type = "[a] -> ContentF a";
  _dir = T.typed "dir";

  # Markup Constructors
  docs.content._tell.type = "{ _data :: AttrSet, _next :: a} -> ContentF a";
  _tell = T.typed "tell";

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

  fmapMatch = f:
    { 
      "*"     = x: x;
      "tell"  = {_data, _next}: _tell { inherit _data; _next = f _next; };
      "text"  = x: _text x;
      "local" = x: _local x;
      "file"  = {_renderType, _next}: _file { inherit _renderType; _next = f _next; };
      "dir"   = {_dirName, _next}: _dir { inherit _dirName; _next = builtins.map f _next; };
    };

  fmap = T.matchWith fmapMatch;
}
