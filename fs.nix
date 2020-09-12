pkgs: types: content: cj:

rec
{
  docs.fs.file.type = "{ _fileName :: FileName, _renderType :: RenderType, _content :: Content } -> FSF a";
  file = types.typed "file";

  docs.fs.dir.type = "{ _dirName :: FilePath, _next :: [a] } -> FSF a";
  dir = types.typed "dir";

  docs.fs.local.type = "FilePath -> FSF a";
  local = types.typed "local";

  docs.fs.pandoc.type = "{ _pandocType :: String, _pandocArgs :: String, _buildInputs :: [Derivation] } -> RenderType";
  pandoc = types.typed "pandoc";

  docs.fs.withFiles.docstr = "`withFiles files x` puts x in a directory with files";
  docs.fs.withFiles.type = "DirName -> [Derivation] -> FSF a -> FSF a";
  withFiles = _dirName: files: fs: dir { inherit _dirName; _next = ((builtins.map local files) ++ [ fs ]); };

  # TODO: write html file creation function:
  # 
  #  * --css flag should only point to files that exist in the final derivation output.
  #  * --metadata pagetitle=... should be set
  #  * otherstatic resouces should be included with `local`.

  # TODO: it will be worth Making File :: ... -> ContentF a -> FSF a and then compose the 
  # evaluator for contentF. This will allow for generating document contents and perform
  # filesystem operations.... for example: image linking:
  #
  #  ```
  #  ''(img {_alt = "A Foo Image"; _path = ./static/foo.png; })''
  #  ```
  #
  # This would then produce:
  #
  #                           granted, this would be in a `file` constructor...
  #                                   |
  #                                   V
  #  dir [ (local ./static/foo.png) (text "![./static/foo.png](A Foo Image)") ]
  #

  docs.fs.markdown.type = "RenderType";
  markdown = types.typed "markdown" null;

  fmapMatch = f:
    { "local" = x: local x;
      "file" = x: file x;
      "dir" = {_dirName, _next}: dir { inherit _dirName; _next = builtins.map f _next; };
    };

  docs.fs.evalRenderType.type = "RenderType -> FileName -> String -> Derivation";
  evalRenderType = types.match
    { "markdown" = _: fileName: pkgs.writeText "${fileName}.md";
      # TODO: split this up into the inital encoding. Right now it's 
      # in final encoding so
      "pandoc" = {_pandocType, _pandocArgs, _buildInputs}: fileName: fileText: 
        pkgs.runCommand "${fileName}.${_pandocType}" { buildInputs = [ pkgs.pandoc ] ++ _buildInputs; }
          ''
            ${pkgs.pandoc}/bin/pandoc -s -o $out ${_pandocArgs} ${fileText}
          '';
    };

  #TODO: refactor the RW evaluator from content.eval and make it more generic.
  docs.fs.evalAlg.type = ''
    (a ~ { data :: AttrSet, drv :: Derivation }, t ~ a -> a) => FSF t -> t
  '';
  evalAlg = types.match
    { "local" = _sourcePath: content.rwM.memptyWithText _sourcePath;
      "file"  = {_fileName, _content, _renderType}: 
        content.rwM.fmap (evalRenderType _renderType _fileName) (content.eval _content);
      "dir" = {_dirName, _next}: 
        content.rwM.fmap (cj.copyJoin false _dirName) (content.rwM.sequence _next);
    };


  eval = types.cata (types.matchWith fmapMatch) evalAlg;
}
