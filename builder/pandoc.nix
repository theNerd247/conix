self: super:

{ conix = (super.conix or {}) // 
  { build = (super.conix.build or {}) //
    rec
    { pandoc = outType: options: name: pages:
        let
          pandoc = self.pandoc;
          outFileName = "${name}.${outType}";
          contents = super.conix.build.markdown name pages;
        in
          self.stdenv.mkDerivation
          { inherit name;
            buildInputs = [ pandoc self.texlive.combined.scheme-small ];
            dontUnpack = true;
            buildPhase = 
              ''
                ${pandoc}/bin/pandoc -s -o ${outFileName} -f markdown ${contents}/${name}.md ${options}
              '';
            installPhase = 
              ''
                mkdir -p $out
                cp ${outFileName} $out/${outFileName}
                cp ${contents}/${name}.md $out/${name}.md
              '';
          };

      pandocFileOpts = outType: options: name: mkModule:
        with super.conix; pandoc options "" name [ (runModule mkModule) ];

      pandocFile = type: pandocFileOpts type "";

      pdfFile = pandocFile "pdf";
      htmlFile = pandocFile "html";
    };
  };
}
