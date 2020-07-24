self: super:

with super.conix;

{ conix = (super.conix or {}) //
  rec
  { 
    table
      # Path -> [ Text ] -> [[Text]] -> Module Text
      = path: headers: rows: 
      let
        hdrs = mkHeaders headers;

        tblContents = foldMapModulesIx rowToModule rows;

        tbl =
          createPageFromModule [] (mergeModules hdrs tblContents);

        rowsLength = 
          hidden (setValue [ "rows" "length" ] (builtins.length rows));

        colsLength =
          hidden (setValue [ "cols" "length" ] (builtins.length headers));
      in
        nestModule path (foldModules [ tbl rowsLength colsLength ]);

    mkHeaders = headers:
      let
        headerSep = builtins.concatStringsSep " | " (builtins.map (x: "---") headers); 
      in
        (nestModule [ "headers"  ] 
          (mapVal (t: t + "\n" + headerSep) (foldMapModulesIx cellToModule headers))
        );

    #TODO: add generating modules where the page keys are
    # the values of the first column and the subkeys are
    # the values of 2nd+ header values and the text values
    # are the corresponding column value for that row. 
    #
    # Here's what's going on here:
    # 1. fold over list of text; creating a module for each cell that returns: 
    #   { pages = { "0" = cell0; }; val = " | " + cell0 }
    #  Note: the folding takes care of concatenating the cell strings together
    # 2. Create a page for the resulting row text:
    #   { pages = { text = "cell0 | cell1 | ..."; "0" = ...; "1" = ...; }; text = "cell0 | cell1 | ... ";}
    # 3. map over the row text and prepend a newline character
    # 4. nest the resulting pages under the row index:
    #   { pages = { "0" = { text = "cell0 | cell1 | ..."; "0" = ...; "1" = ...; } }; text = "\ncell0 | cell1 | ... ";}
    rowToModule = rowIx: columns:
      nestModule [ "row${builtins.toString rowIx}" ]
      ( createPageFromModule [] 
        (mapVal 
          (t: "\n" + t)
          (foldMapModulesIx cellToModule columns)
        )
      );

    cellToModule = colIx: colText:
      mapVal 
        (t: if colIx == 0 then t else " | " + t)
        (text [ "col${builtins.toString colIx}" ] colText);

  };
}
