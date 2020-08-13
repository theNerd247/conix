self: super:

with super.conix;

{ conix = (super.conix or {}) //
  rec
  { git =
    rec
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "3e49df84fa04a7d554ac514bf03416f2db91d2fe";
      ref = "v0.1.0-api";
      text = ''
        { url = "${url}";
          rev = "${rev}";
          ref = "${ref}";
        }
        '';
    };

    lib = super.conix.extendLib super.conix.lib (x:
      { inherit git; }
    );
  };
}
