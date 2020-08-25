conix: { lib = rec
{
  
  docs.using.docstr = ''
    Constructs a derivation from the given module, and then appends
    that to the module's derivations. 
  '';
  docs.using.type = "(Module -> Derivation) -> Module -> Module";
  using = f: module: conix.lib.mergeModules module ({ drvs = [ (f module) ]; });

  docs.as.docstr = ''
    Like `using` but instead of appending the generated derivation, it sets the
    drvs to the generated derivation.
  '';
  docs.as.type = "(Module -> Derivation) -> Module -> Module";
  as = f: module: conix.lib.setDrvs [ (f module) ] module;

  docs.dirWithMarkdown.docstr = ''
    Create a directory called `name` and within it a markdown file called
    `name` whos text is from the given module. The directory also contains
    files produced by any deririvations created in the given module. These
    files are aggregated using `dir`.

    Use this as your toplevel file derivation.

    The returned module's
    ```
    A 
      |- A.md
      |- ... <any otherfiles from the given module's drvs>
    ```
  '';

  docs.dirWithMarkdown.type = "Name -> Module -> Module";
  dirWithMarkdown = name: module: 
    as (m: conix.lib.dir name m.drvs) (using (conix.lib.markdownFile name) module);

  docs.collectWithMarkdown.docstr = builtins.replaceStrings ["`dir`"] ["`collect`"] docs.dirWithMarkdown.docstr;
  docs.collectWithMarkdown.type = "Name -> Module -> Module";
  collectWithMarkdown = name: module: 
    as (m: conix.lib.collect name m.drvs) (using (conix.lib.markdownFile name) module);

}; }
