self: super:

{ conix = (super.conix or {}) // 
  { build = (super.conix.build or {}) //
    rec
    { markdown = name: module:
      { drv = self.writeTextFile "${name}.md" module.text;
      };
    };
  };
}
