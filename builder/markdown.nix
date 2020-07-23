self: super:

{ conix = (super.conix or {}) // 
  { build = (super.conix.build or {}) //
    { markdown = name: pages:
        self.writeTextDir "${name}.md" (builtins.concatStringsSep "\n" (builtins.map (p: p.text) pages));
    };
  };
}
