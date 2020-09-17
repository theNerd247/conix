let
  T = import ./types.nix;
in

rec
{
  # FSF a
  # = Local Derivation
  # | File FileName RenderType a
  # | Dir DirName [a]

  # TODO: rename this to something more universal
  docs.fs.file.type = "{  _renderType :: RenderType } -> FSF";
  file = T.typed "file";

  docs.fs.local.type = "FilePath -> FSF";
  local = T.typed "local";

  docs.fs.dir.type = "{ _fileName :: DirName } -> RenderType";
  dir = T.typed "dir";

  docs.fs.pandoc.type = "{ _fileName :: FileName, _pandocType :: String, _pandocArgs :: String, _buildInputs :: [Derivation] } -> RenderType";
  pandoc = T.typed "pandoc";

  docs.fs.markdown.type = "{_fileName :: FileName} -> RenderType";
  markdown = T.typed "markdown";

  docs.fs.noFile.type = "RenderType";
  noFile = T.typed "noFile" null;

}
