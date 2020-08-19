conix: { lib.md = rec
  {  
    docs.list.docstr = ''
      Create an bullet list style markdown list.
      '';
    docs.list.type = "Name -> [ String ] -> Module";
    list
      = name: rawTexts: 
        let
          texts = builtins.map (builtins.replaceStrings [ "\n" ] [""]) rawTexts;
        in
        { text = builtins.concatStringsSep "\n" (builtins.map (t: "* ${t}") texts);
          ${name} = texts;
        };
  };
}
