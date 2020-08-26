conix: { lib = rec
{
  
  docs.using_.docstr = ''
    Constructs derivations from the given module, and then append
    that to the module's derivations. 
  '';
  docs.using_.type = "(Module -> [Derivation]) -> Module -> Module";
  using_ = f: module: conix.lib.mergeModules module ({ drvs = f module; });

  docs.as_.docstr = ''
    Construct derivations from the given module and then replace that modules
    derivations with the constructed ones.
  '';
  docs.as_.type = "(Module -> [Derivation]) -> Module -> Module";
  as_ = f: module: conix.lib.setDrvs (f module) module;

  docs.using.docstr = ''
    Like `using_` but uses a list of functions that return a single derivation 
    each.

    It's more likely you'll use this instead of `using_`.
  '';
  docs.using.type = "[(Module -> Derivation)] -> Module -> Module";
  using = fs: using_ (a: builtins.map (f: f a) fs) 

  docs.as.docstr = builtins.replaceStrings ["using_"] ["as_"] docs.using.docstr;
  docs.as.type = docs.using.type;
  as = fs: as_ (a: builtins.map (f: f a) fs) 

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
