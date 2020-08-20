conix: { lib = rec
  {  
    docs.md.list.docstr = ''
      Create an bullet list style markdown list.
      '';
    docs.md.list.type = "Name -> [ String ] -> Module";
    md.list
      = name: texts: 
        { text = builtins.concatStringsSep "\n" (builtins.map (t: "* ${t}") texts);
          ${name} = texts;
        };
  };
}
