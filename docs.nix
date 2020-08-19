conix: { lib = rec
{
  docs.mkDocModule.docstr = ''
    Construct markdown content for a documentation data structure 
    '';
  docs.mkDocModule.type = "{ name : String; docstr : String; type : String }";
  docs.mkDocModule.todo = 
    [ "Right now this is not language agnostic...maybe it should be?" 
    ];
  mkDocModule = doc: path: 
    let p = builtins.concatStringsSep "." path; in
    if ! builtins.isAttrs doc then conix.lib.emptyModule else
    conix.lib.texts [ 
      ''
      <hr/>
      ${doc.docstr or ""}
      ''
      ( if doc ? todo 
        then conix.lib.texts 
          [ "_Todo_\n\n" (conix.lib.md.list "todo" doc.todo) ]
        else conix.lib.emptyModule
      )
      ''

      ```haskell
      ${p} :: ${doc.type or (throw "missing docs.${p}.type assignment")}
      ```
      ''
    ];

  collectDocModules = conix.lib.foldAttrsIxCond 
    (s: s ? type)
    mkDocModule
    (moduleMap: conix.lib.foldModules (builtins.attrValues moduleMap));

  refDocs = 
     conix.lib.texts (
      [ ''
        # Conix Documentation - ${conix.lib.version.text}

        ## Reference
        ''
      ] ++
      [ (collectDocModules (builtins.removeAttrs conix.lib.docs ["text" "drv"])) ]
      ++
      [ ''
        ## Discussion

        ### Modules
        
        ${conix.lib.docs.modules.discussion}

        ### Pages

        ${conix.lib.docs.pages.discussion}

        ### Infinite Recursion
        
        ${conix.lib.docs.infiniteRecursion.discussion}

        ---
        Built using ${conix.lib.homePageLink} version ${conix.lib.version.text}
        ''
      ]
    );
};}
