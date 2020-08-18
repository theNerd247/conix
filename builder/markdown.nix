conix: { lib = rec
  { markdownFile = name: module:
    { drv = conix.pkgs.writeTextFile "${name}.md" module.text;
    };
  };
}
