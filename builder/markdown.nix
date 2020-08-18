conix: { lib = rec
  { markdownFile = name: module:
    conix.lib.mergeModules module
      { drv = conix.pkgs.writeText "${name}.md" module.text;
      };
  };
}
