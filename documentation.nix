(import <nixpkgs> { overlays = (import ./default.nix); }).conix.buildPages [
  (conix: { drv = with conix.lib;
      c = collect "conix-docs" (
        conixReferenceDocumentation
        ++ docs.readme.drvs
        ++ docs.goals.drvs
      );
    in
      { drvs = [ c ]; };
})]
