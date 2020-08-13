self: super:

{ conix = (super.conix or {}) // 
  { build = (super.conix.build or {}) //
    rec
    { markdown = {name, text, ...}:
        self.writeTextDir "${name}.md" text;
    };
  };
}
