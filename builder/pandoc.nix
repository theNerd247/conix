conix: { lib = rec
  { 
    docs.pandoc.docstr = ''
      Writes a file of the specified type to the nix store using pandoc.
    '';
    docs.pandoc.todos = [ "Remove hardcoded markdown input type" ];
    docs.pandoc.type = "Name -> Type -> { buildInputs : [ derivation ] } -> Module -> { drv : Derivation }";
    pandoc 
      = name: type: buildInputs: markdownModule:
      let
        fileName = "${name}.${type}";
      
        drv = conix.pkgs.runCommand fileName
          { buildInputs = [ conix.pkgs.pandoc ] ++ buildInputs; }
          ''
            ${conix.pkgs.pandoc}/bin/pandoc -s -o $out -f markdown ${markdownModule.drv} -t ${type}
          '';
      in
        { inherit drv };

    docs.htmlFile.docstr = builtins.replaceStrings ["pdf"] ["html" docs.pdfFile.docstr;
    docs.htmlFile.type = docs.pdfFile.type;
    htmlFile 
      = name: module: pandoc name "html" [];

    docs.pdfFile.docstr = ''
      Writes a pdf file to the nix store given some module who's `drv` builds to a markdown file.
    '';
    docs.pdfFile.type = "Name -> Module -> { drv : derivation }";
    pdfFile 
      = name: module: pandoc name "pdf" [ conix.pkgs.texlive.combined.scheme-small ];
  };
}
