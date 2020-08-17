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

  # We use the free monoid to "merge" derivations for now.
  # NOTE: the _dir AST constructor resets the
  # monoid with a single copyJoin derivation (it's like symlink join).
  mergeDrvs = a: b: a ++ b;
  emptyDrv = [];

  foldDrvs 
    # [ { drv : [ derivation ]; ...} ] -> [ derivation ];
    = builtins.foldl' (a: b: mergeDrvs a b.drv) emptyDrv;

  mergeAttrSets = pkgs.lib.attrsets.recursiveUpdate;

  nest = pkgs.lib.attrsets.setAttrByPath;

  splitString = pkgs.lib.strings.splitString;

in
rec { 
  inherit M finalDrv;

  toAST = x: if (x._type or null) != null then x else M._pure x;

  texts = xs: M._merge (builtins.map toAST xs);

  nixSnippetWith = name: mkOutput: code:
    let
      file = pkgs.writeText name code;
    in
      texts 
        [ (M._codeblock "nix" (M._pure code))
          "\n==>\n"
          (mkOutput file)
        ];

  codeBlock = lang: M._modifyText (t: "```${lang}\n${t}\n```");

  list = bullet: xs:
    M._merge (builtins.map (M._modifyText (t: "${bullet} ${t}\n")) xs);

  table = x: headers: rows:
    let
      # extract text from evaluated headers and rows
      drv = foldDrvs (x.headers ++ (builtins.map foldDrvs x.rows));
    in
      { text = mkTable headers rows; inherit drv; inherit (x) headers rows; };

  # (a ~ { text : String; drv : [ derivation ]; ... }) => ContentF a -> a
  eval = M.matchOn
  { 

      #TODO: Use the free monoid for text as well. This will allow us to strink the AST
      # to a minimal orthogonal size (we don't need to include markdown into the AST).
      # Then all of the markdown utility functions simply will make use of the constructor
      # 
      # _concatWith :: ([Text] -> Text) -> m a -> m a to create blocks of texts, tables, lists, etc. just like 
      # _concatDrv :: ([Dir] -> Dir) -> m a -> m a
      #
      # _merge :: [m a] -> m a
      #
      # mkRow :: [m a] -> m a
      # mkRow = _concatWith (concatStringsSep " | ") (_merge cols)
      #
      # mkRows :: [[m a]] -> [m a]
      # mkRows = builtins.map mkRow;
      #
      # table = _concatWith (concatStringsSep "\n") (_merge (mkRows rows))
      pure = x: { text = builtins.toString x.data; drv = emptyDrv; };

      data = x: mergeAttrSets (builtins.removeAttrs x.data ["text" "drv"]) x.contents;

      modifyText = x:
        let
          text = x.modifyText x.contents.text;
        in
          x.contents // { inherit text; };

      dir = x: 
        let
          drv = pkgs.copyJoin x.path x.contents.drv;
        in
          x.contents // { drv = [ drv ]; };

      include = x: 
        let
          drv = mergeDrvs [x.drv] x.contents.drv;
        in
          x.contents // { inherit drv; };

      label = x:
        (nest (splitString "." x.path) x.contents) // { inherit (x.contents) text drv; };

      merge = x: 
        let
          text = builtins.foldl' (a: r: a+r.text) "" x.contentsList; 
          drv = foldDrvs x.contentsList;
          xs = builtins.foldl' mergeAttrSets {} x.contentsList;
        in
          xs // { inherit text drv; };

    };
}
