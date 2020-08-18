conix: { lib = rec
{
  mkDocLine = name: func: conix.lib.text (
      if func ? docstr then ''

      ${func.docstr or ""}
      ${name} : `${func.type or (throw "${name} missing docs.${name}.type assignment")}`

      ''
      else ""
    );

  refDocs = 
    let 
      docsText = 
        conix.lib.texts (
          conix.pkgs.lib.attrsets.mapAttrsToList
          mkDocLine
          (builtins.removeAttrs conix.lib.docs ["text" "drv"])
        );

      drv = conix.lib.markdownFile "conixDocs" docsText;
    in
      conix.lib.mergeModules docsText drv;

};}
