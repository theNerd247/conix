conix: { lib = rec
  {  
    docs.md.list.docstr = ''
      Create an bullet list style markdown list.
      '';
    docs.md.list.type = "Name -> [ Module ] -> Module";
    md.list
      = name: ms:
        let
          modules = builtins.map conix.lib.toTextModule ms;
          text = builtins.concatStringsSep "\n" (builtins.map (m: "* ${m.text}") modules);
        in
          conix.lib.mergeModules ((conix.lib.foldModules modules) // { inherit text; }) { ${name} = ms; };
  };
}
