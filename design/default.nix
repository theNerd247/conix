self: super:

{ conix = (super.conix or {}) //
  rec
  { docs.design = 
      [ (import ./goals.nix)
        (import ./core.nix)
      ];
  };
}
