self: super:

{ conix = (super.conix or {}) // 
  { build = (super.conix.build or {}) //
    rec
    { markdown = name: pages:
        self.writeTextDir "${name}.md" (builtins.concatStringsSep "\n" (builtins.map (p: p.text) pages));

      markdownFile = name: module:
        markdown name (builtins.attrValues (super.conix.buildPageSet module));
    };
  };
}
