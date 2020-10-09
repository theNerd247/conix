(import <nixpkgs> { overlays = import ./default.nix; }).conix.run [
  (conix: { drv = with conix.lib;
    collect "conix-docs" 
      [ (buildBoth "docs" conixReferenceDocumentation (markdownFile "docs") (htmlFile "docs" ""))
        (buildBoth "readme" docs.readme (markdownFile "readme") (htmlFile "readme" ""))
        (buildBoth "goals" docs.goals (markdownFile "goals") (htmlFile "goals" ""))
      ];
})]
