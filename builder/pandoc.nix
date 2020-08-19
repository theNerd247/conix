conix: { lib = rec
  { 
    docs.pandoc.docstr = ''
      Writes a file of the specified type to the nix store using pandoc.
    '';
    docs.pandoc.todo = [ "Remove hardcoded markdown input type" ];
    docs.pandoc.type = "Name -> Type -> { buildInputs : [ Derivation ] } -> (FilePath | Derivation) -> Derivation";
    pandoc 
      = name: type: buildInputs: markdownFile:
      let
        fileName = "${name}.${type}";
      in
        conix.pkgs.runCommand fileName
          { buildInputs = [ conix.pkgs.pandoc ] ++ buildInputs; }
          ''
            ${conix.pkgs.pandoc}/bin/pandoc -s -o $out -f markdown ${markdownFile} -t ${type}
          '';

    docs.htmlFile.docstr = builtins.replaceStrings ["pdf"] ["html"] docs.pdfFile.docstr;
    docs.htmlFile.type = docs.pdfFile.type;
    docs.htmlFile.todo = [ 
      ''
      Add the ability to auto-include static resources as part of the
      produced derivation.  For example `--css ./filePath` would be generated
      via some statement stating to include ./filePath as a css resource.
      ''
    ];
    htmlFile 
      = name: pandoc name "html" [];

    docs.pdfFile.docstr = ''
      Writes a pdf file to the nix store given some module who's `drv` builds to a markdown file.
    '';
    docs.pdfFile.type = "Name -> (FilePath | Derivation) -> Derivation";
    pdfFile 
      = name: pandoc name "pdf" [ conix.pkgs.texlive.combined.scheme-small ];

    docs.buildBoth.docstr = ''
      Run the first builder and then pass its output to the second builder.
      Collect both the resulting derivations into a directory with the given
      name. 

      Typically this should be used with `htmlFile` or `pandocFile`.
      '';
    docs.buildBoth.type = "Name -> a -> (a -> Derivation) -> ((FilePath | Derivation) -> Derivation) -> Derivation";
    buildBoth 
      = name: module: f: g:
      let
        drvA = f module;
        drvB = g drvA;
      in
        conix.lib.collect name [ drvA drvB ];
  };
}
