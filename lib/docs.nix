pkgs:

let
  F = import ./foldAttr.nix pkgs;
  C = import ./content.nix pkgs;
in
with C;
{

  with (import ./modules.nix);

  module
  {
    f = expr "Int -> Int" "Documented f" (x: x + 1);
  }

  docs.mkDocModule = document "A -> B -> C -> D" '' .... '';
  mkDocModule = doc: path: 
    let p = builtins.concatStringsSep "." path; in
    if ! builtins.isAttrs doc then "" else
    ;

  collectDocModules = F.foldAttrsIxCond 
    (s: s ? type || s ? docstr)
    mkDocModule
    (moduleMap: builtins.attrValues moduleMap);
}
