conix: { lib = rec
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
          (conix.pkgs.lib.lists.range 0 ((builtins.stringLength text) - 1));

        lastLine = if linesAndLine.line == null then [] else [linesAndLine.line];
      in
        linesAndLine.lines ++ lastLine;

    overLines = f: text:
      (builtins.concatStringsSep "\n" (f (splitLines text)));

    docs.extractLines.docstr = ''
      Extract lines of text within the given line range (start and end inclusive).

      This is handy for grabbing certain lines of, say a code block.
    '';
    docs.extractLines.type = "NaturalGreaterThan0 -> Natural -> String -> String";
    extractLines = start: end: overLines
      (conix.pkgs.lib.lists.sublist 
        (start - 1) 
        (end - start + 1)
      );

    docs.indent.docstr = ''
      Indent lines in the given string by an integer number of spaces
    '';
    docs.indent.type = "Natural -> String -> String";
    indent = n:
      let
        buffer = builtins.concatStringsSep "" (builtins.genList (_: " ") n);
      in
        builtins.replaceStrings ["\n"] ["\n${buffer}"];
  };
}
