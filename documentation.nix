(import <nixpkgs> { overlays = (import ./default.nix); }).conix.buildPages [
  (conix: { drv = with conix.lib;
    let
      c = dir "conix-docs" (
           docs.readme.drvs
        ++ [ (dir "docs" (
          conixReferenceDocumentation.drvs
          ++ docs.goals.drvs
          ++ docs.integration.drvs
        ))] 
      );
    in
      { drvs = [ c ]; };
})]
