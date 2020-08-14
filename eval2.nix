let
  M = import ./alg.nix;

  pkgs = import <nixpkgs> {};

  rowText = xs:
    builtins.concatStringsSep " | " (builtins.map builtins.toString xs);

  lines = builtins.concatStringsSep "\n";

  mkTable 
    = headers: rowsOfColumns: lines
        [ (rowText headers)
          (rowText (builtins.map (_: "---") headers))
          (lines (builtins.map rowText rowsOfColumns))
        ];

  mergeDrvs = throw "Not defined";
  mergeAttrSets = pkgs.lib.attrsets.recursiveUpdate;
  nest = pkgs.lib.attrsets.setAttrByPath;
  splitString = pkgs.lib.strings.splitString;
in
rec { 
  inherit M;

  eval = M.matchOn
    { pure = x: { text = builtins.toString x.data; drv = {}; };

      codeblock = x: x.contents // { text = "```${x.text}```"; };

      data = x: mergeAttrSets (builtins.removeAttrs x.data ["text" "drv"]) x.contents;

      dir = x: throw "Evaluator for 'dir' not implemented!";

      file = x: 
        let
          fileDrv = pkgs.writeText x.name x.contents.text;
          drv = mergeDrvs [ fileDrv x.drv ]; 
        in
          x.contents // { inherit drv; };

      include = x: throw "Evaluator for 'include' not implemented!";

      label = x:
        (nest (splitString "." x.path) x.contents) // { inherit (x.contents) text drv; };

      list = x: 
        let
          items = builtins.map (i: "1. ${i.text}") x.contentsList;
          drv = mergeDrvs x.contentsList;
        in
          { text = builtins.concatStringsSep "\n" items; inherit drv; items = x.contentsList; };

      merge = x: 
        let
          text = builtins.concatStringsSep "" x.contentsList; 
          drv = mergeDrvs x.contentsList;
          xs = builtins.foldl' mergeAttrSets {} x.contentsList;
        in
          xs // { inherit text drv; };

      table = x: 
        let
          # extract text from evaluated headers and rows
          headers = builtins.map (h: h.text) x.headers;
          rows = builtins.map (builtins.map (c: c.text)) x.rows;
          drv = mergeDrvs (x.headers ++ (builtins.map mergeDrvs x.rows));
        in
          { text = mkTable headers rows; inherit drv; inherit (x) headers rows; };
    };
}
