conix: { lib = rec
{
  mkDocLine = name: func: conix.lib.text (
      if func ? docstr then ''

      ${func.docstr or ""}

      ```haskell
      ${name} :: ${func.type or (throw "${name} missing docs.${name}.type assignment")}
      ```

      ''
      else ""
    );

  refDocs = 
     conix.lib.texts (
      [ ''
        # Conix Documentation

        ## Reference
        ''
      ] ++
      (
        conix.pkgs.lib.attrsets.mapAttrsToList
        mkDocLine
        (builtins.removeAttrs conix.lib.docs ["text" "drv"])
      ) ++
      [ ''
        ## Discussion

        ### Modules
        ''
        conix.lib.docs.modules.discussion
      ]
    );
};}
