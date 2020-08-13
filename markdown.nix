self: super:
  
{ conix = (super.conix or {}) //
  rec
  {  
    list
      = name: rawTexts: 
        let
          texts = builtins.map (builtins.replaceStrings [ "\n" ] [""]) rawTexts;
        in
        { text = builtins.concatStringsSep "\n" (builtins.map (t: "1. ${t}") texts);
          ${name} = texts;
        };

    lib = super.conix.extendLib super.conix.lib (x:
      { md = { inherit list; };
      }
    );
  };
}
