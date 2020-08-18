conix: { lib = rec
  { pandoc = name: type: buildInputs: module:
      let
        contents = (conix.lib.markdownFile name module).drv;
        fileName = "${name}.${type}";
      
        drv = conix.pkgs.stdenv.mkDerivation
        { inherit name;
          buildInputs = [ conix.pkgs.pandoc ] ++ buildInputs;
          dontUnpack = true;
          buildPhase = 
            ''
              ${conix.pkgs.pandoc}/bin/pandoc -s -o ${fileName} -f markdown ${contents}
            '';
          installPhase = 
            ''
              mkdir -p $out
              cp ${fileName} $out/${fileName}
              cp ${contents} $out/${name}.md
            '';
        };
      in
        { inherit drv; };

    htmlFile = name: pandoc name "html" [];

    pdfFile = name: pandoc name "pdf" [ conix.pkgs.texlive.combined.scheme-small ]; 
  };
}
