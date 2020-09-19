let
  T = import ./types.nix;
in

# Re-export constructors to build the toplevel api
rec
{ 
  # Main API
  local    = _local;
  dir      = _dir;
  markdown = _markdown;
  pandoc   = _pandoc;
  text     = _text;

  docs.content.file.type = "RenderType -> [Content] -> Content";
  file = _renderType: content: 
    _file { inherit _renderType; _next = _merge content; };

  docs.content.label.type = "AttrSet -> Content -> Content";
  label = _data: _next: _tell { inherit _data _next; };

  # Internals
  #
  # TODO: if this grows large move to its own module
  # right now I'm lazy....

  docs.content._merge.type = "[a] -> ContentF a";
  _merge = T.typed "merge";

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
  docs.content._dir.type = "{ _fileName :: DirName } -> RenderType";
  _dir = T.typed "dir";

  docs.content._pandoc.type = "{ _fileName :: FileName, _pandocType :: String, _pandocArgs :: String, _buildInputs :: [Derivation] } -> RenderType";
  _pandoc = T.typed "pandoc";

  docs.content._markdown.type = "{_fileName :: FileName} -> RenderType";
  _markdown = T.typed "markdown";
}
