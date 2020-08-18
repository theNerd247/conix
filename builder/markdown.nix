conix: { lib = rec
{ 
  docs.markdownFile.docstr = ''
    Builds a markdown file derivation with the given name to the nix store.
  '';
  docs.markdownFile.todo = ["Maybe refactor the text out?"];
  docs.markdownFile.type = "Name -> Module -> { drv : derivation }";
  markdownFile = name: module:
      { drv = conix.pkgs.writeText "${name}.md" module.text;
      };
}; }
