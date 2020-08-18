rec { 

  pkgs = import <nixpkgs> {
    overlays = [ (import ./copyJoin.nix) ];
  };

  W = import ./writerF.nix;

  C = import ./alg.nix;

  rowText = xs:
    builtins.concatStringsSep " | " (builtins.map builtins.toString xs);

  lines = builtins.concatStringsSep "\n";

  mkTable 
    = headers: rowsOfColumns: lines
        [ (rowText headers)
          (rowText (builtins.map (_: "---") headers))
          (lines (builtins.map rowText rowsOfColumns))
        ];

  nest = pkgs.lib.attrsets.setAttrByPath;

  pathToList = pkgs.lib.strings.splitString ".";

  mconcatDatas = builtins.foldl' pkgs.lib.attrsets.recursiveUpdate {};

  toAST = x: 
    if (x._type or false) then x else
    if builtins.isString x then text x else
    data x;

  text = t: x: C._texts (W._tell t x);


  label = path: t: x: 
    data (pkgs.lib.attrsets.setAttrByPath (pathToList path) t) (text (builtins.toString t) x);

  data = d: x: C._datas (W._tell d x);

  # (Module a -> a) -> Fix Module -> a
  cata = x: C.eval (C.fmap cata x);

  run = mkAst: pkgs.lib.fix (x: cata (mkAst (mconcatDatas x.datas)));

  testExpr = c: 
    text "foo " (
    label "x" 3 (
    text "blarg - " (
    label "y" (c.x + 3) C._end
  )));

  n = run testExpr;
}
