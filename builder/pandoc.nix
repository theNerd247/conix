self: super:

{ conix = (super.conix or {}) // 
  { build = (super.conix.build or {}) //
    rec
    { pandoc_ = deps: outType: name: pages:
        let
          pandoc = self.pandoc;
          outFileName = "${name}.${outType}";
          contents = super.conix.build.markdown name pages;
        in
          self.stdenv.mkDerivation
          { inherit name;
            buildInputs = [ pandoc ] ++ deps;
            dontUnpack = true;
            buildPhase = 
              ''
                ${pandoc}/bin/pandoc -s -o ${outFileName} -f markdown ${contents}/${name}.md
              '';
            installPhase = 
              ''
                mkdir -p $out
                cp ${outFileName} $out/${outFileName}
                cp ${contents}/${name}.md $out/${name}.md
              '';
          };

      pandoc = pandoc_ [];

      pandocFile_ = deps: outType: name: mkModule:
        with super.conix; pandoc_ deps outType name [ (runModule mkModule) ];

      pdfFile = pandocFile_ [ self.texlive.combined.scheme-small ] "pdf";
      htmlFile = pandocFile_ [] "html";
    };
  };
}
