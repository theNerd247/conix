self: super:
  
{ conix = (super.conix or {}) //
  rec
  {  
    splitLines = text:
      let
        splitLines_ = {lines, line}: ix:
          let 
            char = builtins.substring ix 1 text;
            newLine = if line == null then char else "${line}${char}";
          in
            if char == "\n"
              then { lines = lines ++ [ line ]; line = null; }
              else { lines = lines; line = newLine; };

        linesAndLine = builtins.foldl'
          splitLines_ 
          { lines = []; line = null; } 
          (super.lib.lists.range 0 ((builtins.stringLength text) - 1));

        lastLine = if linesAndLine.line == null then [] else [linesAndLine.line];
      in
        linesAndLine.lines ++ lastLine;

    overLines = f: text:
      (builtins.concatStringsSep "\n" (f (splitLines text)));

    extractLines = start: end: overLines
      (super.lib.lists.sublist 
        (start - 1) 
        (end - start + 1)
      );

    indent = n:
      let
        buffer = builtins.concatStringsSep "" (builtins.genList (_: " ") n);
      in
        builtins.replaceStrings ["\n"] ["\n${buffer}"];

    lib = super.conix.extendLib super.conix.lib (x:
      { inherit splitLines extractLines indent;
      }
    );

  };
}
