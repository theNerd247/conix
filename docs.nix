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
        # Conix Documentation - ${conix.lib.version.text}

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
        ''

        ---
        Built using ${conix.lib.homePageLink} version ${conix.lib.version.text}
        ''
      ]
    );
};}
