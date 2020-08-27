conix: { lib = rec
{
  mkDocModule = doc: path: 
    let p = builtins.concatStringsSep "." path; in
    if ! builtins.isAttrs doc then conix.lib.emptyModule else
    conix.lib.texts [ 
      ''
      <hr/>
      ''
      (doc.docstr or conix.lib.emptyModule)
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

  docs.mkDocs.docstr = conix.lib.texts [''
    Creates a module containing markdown documentation of an nested attribute set
    where the leaves are docs.

    A doc is:

    ```
    Doc = ''(conix.lib.label "docType" "{ docstr : String; type = String; todo = [ String ]; }")''
    ```

    Conix uses this to produce its own reference documentation by setting the
    `conix.lib.docs` attribute set in its pages and then creates an html
    derivation by calling this function and passing the resulting module to
    `htmlFile` and `markdownFile`.  
  ''];
  docs.mkDocs.type = "AttrSet -> Module";
  mkDocs = docsAttrSet:
      collectDocModules (builtins.removeAttrs docsAttrSet ["text" "drv"]);

  conixReferenceDocumentation = with conix.lib; using [(markdownFile "docs") (htmlFile "docs" "--metadata title=docs")] (texts [
      ''
      # Reference Documentation - ${conix.lib.version.text}

      ''
      (mkDocs conix.lib.docs)
      ''
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
    ]);
};}
