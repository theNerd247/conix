conix: { lib = rec
  { pandoc = name: type: buildInputs: markdownModule:
      let
        fileName = "${name}.${type}";
      
        drv = conix.pkgs.runCommand fileName
          { buildInputs = [ conix.pkgs.pandoc ] ++ buildInputs; }
          ''
            ${conix.pkgs.pandoc}/bin/pandoc -s -o $out -f markdown ${markdownModule.drv} -t ${type}
          '';
      in
        conix.lib.mergeModules markdownModule { inherit drv markdownModule; };

    htmlFile = name: module: pandoc name "html" [] (conix.lib.markdownFile name module);

    pdfFile = name: module: pandoc name "pdf" [ conix.pkgs.texlive.combined.scheme-small ] (conix.lib.markdownFile name module);
  };
}
