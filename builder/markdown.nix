conix: { lib = rec
  { markdownFile = name: module:
    { drv = conix.pkgs.writeText "${name}.md" module.text;
    };
  };
}
