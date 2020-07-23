self: super:

{ conix = (super.conix or {}) // 
  { build = (super.conix.build or {}) //
    { pdf = name: pages:
        let
          pandoc = self.pandoc;
          outFileName = "${name}.pdf";
          contents = super.conix.build.markdown name pages;
        in
          self.stdenv.mkDerivation
          { inherit name;
            buildInputs = [ pandoc self.texlive.combined.scheme-small ];
            dontUnpack = true;
            buildPhase = 
              ''
                ${pandoc}/bin/pandoc -s -o ${outFileName} -f markdown ${contents}/${name}.md
              '';
            installPhase = 
              ''
                mkdir -p $out
                cp ${outFileName} $out/${outFileName}
              '';
          };
    };
  };
}
