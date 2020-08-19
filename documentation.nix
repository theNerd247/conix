(import <nixpkgs> { overlays = (import ./default.nix); }).conix.build
  (conix: { drv = with conix.lib;
    collect "conix-docs" 
      [ (buildBoth "docs" refDocs (markdownFile "docs") (htmlFile "docs"))
        (buildBoth "readme" docs.readme (markdownFile "readme") (htmlFile "readme"))
      ];
  })
