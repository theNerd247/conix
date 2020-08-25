(import <nixpkgs> { overlays = (import ./default.nix); }).conix.buildPages [
  (import ./readme/default.nix)
  (import ./design/goals.nix)
  (conix: { drv = with conix.lib;
    let
      d = texts
      [ ''
        # Reference Documentation - ${conix.lib.version.text}

        ''
        (mkDocs conix.lib.docs)
        ''
        ## Discussion

        ### Modules
        
        ${conix.lib.docs.modules.discussion}

        ### Pages

        ${conix.lib.docs.pages.discussion}

        ### Infinite Recursion
        
        ${conix.lib.docs.infiniteRecursion.discussion}

        ---
        Built using ${conix.lib.homePageLink} version ${conix.lib.version.text}
        ''
      ];

      c = collect "conix-docs" 
        [ (buildBoth "docs" d (markdownFile "docs") (htmlFile "docs" ""))
          (buildBoth "readme" docs.readme (markdownFile "readme") (htmlFile "readme" ""))
          (buildBoth "goals" docs.goals (markdownFile "goals") (htmlFile "goals" ""))
        ];
    in
      { drvs = [ c ]; };
})]
