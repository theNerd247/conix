conix: { lib.md = rec
  {  
    docs.list.docstr = ''
      Create an bullet list style markdown list.
      '';
    docs.list.type = "Name -> [ String ] -> Module";
    list
      = name: texts: 
        { text = builtins.concatStringsSep "\n" (builtins.map (t: "* ${t}") texts);
          ${name} = texts;
        };
  };
}
