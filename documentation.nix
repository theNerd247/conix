(import <nixpkgs> { overlays = (import ./default.nix); }).conix.buildPages [
  (conix: { drv = with conix.lib;
    let
      c = collect "conix-docs" (
        conixReferenceDocumentation.drvs
        ++ docs.readme.drvs
        ++ docs.goals.drvs
      );
    in
      { drvs = [ c ]; };
})]
