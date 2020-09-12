pkgs: types: content: cj:

rec
{
  docs.fs.file.type = "{ _fileName :: FileName, _renderType :: RenderType, _content :: Content } -> FSF a";
  file = types.typed "file";

  docs.fs.dir.type = "{ _dirName :: FilePath, _next :: [a] } -> FSF a";
  dir = types.typed "dir";

  docs.fs.local.type = "FilePath -> FSF a";
  local = types.typed "local";

  docs.fs.pandoc.type = "{ _pandocArgs :: String, _buildInputs :: [Derivation] } -> RenderType";
  pandoc = types.typed "pandoc";

  docs.fs.markdown.type = "RenderType";
  markdown = types.typed "markdown" null;

  fmapMatch = f:
    { "local" = x: local x;
      "file" = x: file x;
      "dir" = {_dirName, _next}: dir { inherit _dirName; _next = builtins.map f _next; };
    };

  runPandoc = _fileName: {_pandocType, _pandocArgs, _buildInputs}: fileText: pkgs.runCommand "${_fileName}.${_pandocType}"
    { buildInputs = [ pkgs.pandoc ] ++ _buildInputs; }
    ''
      ${pkgs.pandoc}/bin/pandoc -s -o $out ${_pandocArgs} ${fileText}
    '';

  #TODO: refactor the RW evaluator from content.eval and make it more generic.
  docs.fs.evalAlg.type = ''
    (a ~ { data :: AttrSet, drv :: Derivation }, t ~ a -> a) => FSF t -> t
  '';
  evalAlg = types.match
    { "local" = _sourcePath: content.rwM.memptyWithText _sourcePath;
      "file"  = {_fileName, _content, _renderType}: content.rwM.fmap
        ( types.match
          { "markdown" = _: pkgs.writeText "${_fileName}.md";
            # TODO: split this up into the inital encoding. Right now it's 
            # in final encoding so
            "pandoc" = x: runPandoc _fileName x;
          }
          _renderType
        ) (content.eval _content);
      "dir" = {_dirName, _next}: 
        content.rwM.fmap (cj.copyJoin false _dirName) (content.rwM.sequence _next);
    };


  eval = types.cata (types.matchWith fmapMatch) evalAlg;
}
