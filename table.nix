self: super:

with super.conix;

{ conix = (super.conix or {}) //
  rec
  { 
    table
      # [ Text ] -> [[Text]] -> Module
      = headers: rowsOfColumns: rec
        { text = lines
            [ (rowText headers)
              (rowText (builtins.map (_: "---") headers))
              (lines (builtins.map rowText rowsOfColumns))
            ];

          data = rowsOfColumns;

          at 
            # Natural -> [a] -> a
            = row: col:
              builtins.elemAt 
                (builtins.elemAt data row)
                col;
        };

    rowText = xs:
      builtins.concatStringsSep " | " (builtins.map builtins.toString xs);

    lines = builtins.concatStringsSep "\n";

    lib = super.conix.extendLib super.conix.lib (x:
      { inherit 
        table;
      }
    );
  };
}
