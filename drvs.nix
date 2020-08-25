conix: { lib = rec
{
  
  docs.using.docstr = ''
    Constructs a derivation from the given module, and then appends
    that to the module's derivations. 
  '';
  docs.using.type = "(Module -> Derivation) -> Module -> Module";
  using = f: module: conix.lib.mergeModules module ({ drvs = [ (f module) ]; });

  docs.dirWithMarkdown.docstr = ''
    Create a directory called `name` and within it a markdown file called
    `name` whos text is from the given module. The directory also contains
    files produced by any deririvations created in the given module. These
    files are aggregated using `dir`.

    Use this as your toplevel file derivation.
  '';

  docs.dirWithMarkdown.type = "Name -> Module -> Module";
  dirWithMarkdown = name: module: 
    using (m: conix.lib.dir name m.drvs) (using (markdownFile name) module);

  docs.collectWithMarkdown.docstr = builtins.replaceStrings ["`dir`"] ["`collect`"];
  docs.collectWithMarkdown.type = "Name -> Module -> Module";
  collectWithMarkdown = name: module: 
    using (m: conix.lib.collect name m.drvs) (using (markdownFile name) module);

}; }
