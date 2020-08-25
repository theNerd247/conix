conix: { lib = rec
  {  
    foldNull = b: f: x: if x == null then b else f x;

    docs.splitLines.type = "String -> [String]";
    splitLines = text:
      let
        collectLines = len: 
          let
            char = builtins.substring (len - 1) 1 text;
          in
            if len == 0 then { lines = []; line = ""; }
            else let l = collectLines (len - 1); in
            if char == "\n" then { lines = l.lines ++ [l.line]; line = ""; }
            else { lines = l.lines; line = "${l.line}${char}"; };

        linesAndLine = collectLines (builtins.stringLength text);
      in
        linesAndLine.lines ++ [linesAndLine.line];

    docs.overLines.type  = "([String] -> [String]) -> String -> String";
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
      Indent all lines (except the first one) in the given string by an integer
      number of spaces.
    '';
    docs.indent.type = "Natural -> String -> String";
    indent = n: 
      let 
        buffer = builtins.concatStringsSep "" (builtins.genList (_: " ") n);
      in
       builtins.replaceStrings ["\n"] ["\n${buffer}"];

    docs.prefixLines.docstr = conix.lib.texts [''
      Prefix each line with the given text. For example, to make a block of text a block
      quote do: 

      ''(conix.lib.sampleConixSnippet "prefixLinesSample" ''
      text (conix.lib.prefixLines "> "
        '''
        this 
        is a 
        code block'''
      )
      '')
      ];
    docs.prefixLines.type = "String -> String -> String";
    prefixLines = prefix: str: prefix+(builtins.replaceStrings ["\n"] ["\n${prefix}"] str);

    docs.lineNumbers.docstr = ''
      Prefix lines with their line numbers.
      '';
    docs.lineNumbers.type = "String -> String";
    lineNumbers = overLines 
      (conix.lib.foldlIx 
        (ix: strs: str: strs ++ ["${builtins.toString (ix + 1)} ${str}"]) []
      );
  };
}
