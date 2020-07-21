self: super:

{ conix = (super.conix or {}) // 
  { build = (super.conix.build or {}) //
    { pdf = name: pages:
        let
          pagesContents = builtins.map (p: p.text) pages;
          pandoc = self.pandoc;
          outFileName = "${name}.pdf";

          contents = self.writeText "${name}-content" (builtins.concatStringsSep "\n" pagesContents);
        in
          self.stdenv.mkDerivation
          { inherit name;
            buildInputs = [ pandoc self.texlive.combined.scheme-small ];
            dontUnpack = true;
            buildPhase = 
              ''
                ${pandoc}/bin/pandoc -s -o ${outFileName} -f markdown ${contents}
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
