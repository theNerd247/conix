self: super:

{ conix = (super.conix or {}) // 
  { build = (super.conix.build or {}) //
    rec
    { pandoc = args@{buildInputs ? [], name, type, ...}:
        let
          contents = super.conix.build.markdown args;
          fileName = "${name}.${type}";
        in
          self.stdenv.mkDerivation
          { inherit name;
            buildInputs = [ self.pandoc ] ++ buildInputs;
            dontUnpack = true;
            buildPhase = 
              ''
                ${self.pandoc}/bin/pandoc -s -o ${fileName} -f markdown ${contents}/${name}.md
              '';
            installPhase = 
              ''
                mkdir -p $out
                cp ${fileName} $out/${fileName}
                cp ${contents}/${name}.md $out/${name}.md
              '';
          };

      htmlFile = args: pandoc
        (args // { type = "html"; });

      pdfFile = args: pandoc 
        ( args // 
          { type = "pdf"; 
            buildInputs = [ self.texlive.combined.scheme-small ]; 
          }
        );
    };
  };
}
