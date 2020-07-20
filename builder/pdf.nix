self: super:

{ conix = (super.conix or {}) // 
  { build = (super.conix.build or {}) //
    { pdf = name: pages:
        let
          pagesContents = builtins.map (p: p.contents) pages;
          pandoc = self.pandoc;
          outFileName = "${name}.pdf";
        in
          self.stdenv.mkDerivation
          { inherit name;
            buildInputs = [ pandoc self.texlive.combined.scheme-small ];
            dontUnpack = true;
            buildPhase = 
              ''
                echo -En '${builtins.concatStringsSep "\n" pagesContents}' \
                  | ${pandoc}/bin/pandoc -s -o ${outFileName} -f markdown
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
