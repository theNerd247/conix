conix: { lib = rec
{ 
  docs.markdownFile.docstr = ''
    Builds a markdown file derivation with the given name to the nix store.
  '';
  docs.markdownFile.todo = ["Maybe refactor the text out?"];
  docs.markdownFile.type = "Name -> Module -> Module";
  markdownFile = name: module:
      { drv = conix.pkgs.writeText "${name}.md" module.text;
      };

  docs.using.docstr = ''
    This is a quick fix function to merge the result of a builder with the 
    module that produced it. The goal is to give the user less things to
    worry about when creating modules.
    '';
  docs.using.type = "(Module -> Module) -> Module -> Module";
  using = builder: module: 
    conix.lib.mergeModules module (builder module);
}; }
