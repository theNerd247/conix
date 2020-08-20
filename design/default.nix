self: super:

{ conix = (super.conix or {}) //
  rec
  { docs = (super.conix.docs or []) ++
      [ (import ./goals.nix)
        (import ./core.nix)
        (import ./main.nix)
      ];
  };
}
