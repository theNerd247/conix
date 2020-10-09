pkgs:

let
  F = import ./foldAttr.nix pkgs;
  C = import ./content.nix pkgs;
in
with C;
{

  # a.docs = { x = content; y = content; }
  # 
  # f = document "..." "..." (x: y: ...)
  #
  #
  # CodeF a =
  #   = Expr TypeString DocString <expr>
  #   | Module (Map Name a)
  #   | WithPackage (Pkgs -> a)
  #   deriving (Functor)

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
