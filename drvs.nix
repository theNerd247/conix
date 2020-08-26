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
  using = fs: using_ (apply1 fs);

  docs.as.docstr = builtins.replaceStrings ["using_"] ["as_"] docs.using.docstr;
  docs.as.type = docs.using.type;
  as = fs: as_ (apply1 fs);

  docs.usingDir.docstr = ''
    Like `using` but nest all of the created derivations under a directory with
    the given name.
    '';
  docs.usingDir.type = "Name -> [(Module -> Derivation)] -> Module -> Module";
  usingDir = name: fs: using_ (m: conix.lib.dir name (apply1 fs m));

  docs.asDir.docstr = builtins.replaceStrings ["`using`"] ["`as`"] docs.usingDir.docstr;
  docs.asDir.type = docs.usingDir.type;
  asDir = name: fs: as_ (m: conix.lib.dir name (apply1 fs m));

  # [(a -> b)] -> a -> [b]
  apply1 = fs: x: builtins.map (f: f x) fs;
}; }
