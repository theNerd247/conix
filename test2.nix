let
  M = import ./alg.nix;

  pkgs = import <nixpkgs> {
    overlays = [ (import ./copyJoin.nix) ];
  };

  rowText = xs:
    builtins.concatStringsSep " | " (builtins.map builtins.toString xs);

  lines = builtins.concatStringsSep "\n";

  mkTable 
    = headers: rowsOfColumns: lines
        [ (rowText headers)
          (rowText (builtins.map (_: "---") headers))
          (lines (builtins.map rowText rowsOfColumns))
        ];

  mergeDrvs = a: b: a ++ b;
  emptyDrv = [];
  foldDrvs = builtins.foldl' (a: b: mergeDrvs a b.drv) emptyDrv;
  mergeAttrSets = pkgs.lib.attrsets.recursiveUpdate;
  nest = pkgs.lib.attrsets.setAttrByPath;
  splitString = pkgs.lib.strings.splitString;

  finalDrv = name: res: pkgs.copyJoin name res.drv;

  # Module -> AST?
in
rec { 
  inherit M finalDrv;

  n = finalDrv "foos" 
  (M.cata eval 
    (M._dir "bar"
      (M._file "foo" 
        (M._include ./builder 
          (texts ["foo bar: " (M._label "baz" (M._pure 3)) ])
  ))));

  toAST = x: if (x._type or null) != null then x else M._pure x;

  texts = xs: M._merge (builtins.map toAST xs);

  eval = M.matchOn
    { pure = x: { text = builtins.toString x.data; drv = emptyDrv; };

      codeblock = x: x.contents // { text = "```${x.text}```"; };

      data = x: mergeAttrSets (builtins.removeAttrs x.data ["text" "drv"]) x.contents;

      dir = x: 
        let
          drv = pkgs.copyJoin x.path x.contents.drv;
        in
          x.contents // { drv = [ drv ]; };

      file = x: 
        let
          fileDrv = pkgs.writeText x.name x.contents.text;
          drv = mergeDrvs x.contents.drv [fileDrv]; 
        in
          x.contents // { inherit drv; };

      include = x: x.contents // { drv = mergeDrvs [x.filePath] x.contents.drv; };

      label = x:
        (nest (splitString "." x.path) x.contents) // { inherit (x.contents) text drv; };

      list = x: 
        let
          items = builtins.map (i: "1. ${i.text}") x.contentsList;
          drv = foldDrvs x.contentsList;
        in
          { text = builtins.concatStringsSep "\n" items; inherit drv; items = x.contentsList; };

      merge = x: 
        let
          text = builtins.concatStringsSep "" (builtins.map (r: r.text) x.contentsList); 
          drv = foldDrvs x.contentsList;
          xs = builtins.foldl' mergeAttrSets {} x.contentsList;
        in
          xs // { inherit text drv; };

      table = x: 
        let
          # extract text from evaluated headers and rows
          headers = builtins.map (h: h.text) x.headers;
          rows = builtins.map (builtins.map (c: c.text)) x.rows;
          drv = foldDrvs (x.headers ++ (builtins.map foldDrvs x.rows));
        in
          { text = mkTable headers rows; inherit drv; inherit (x) headers rows; };
    };
}
