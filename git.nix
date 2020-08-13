self: super:

with super.conix;

{ conix = (super.conix or {}) //
  rec
  { git =
    rec
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "1294759777c4bd9b3e237e446480b67effb9282a";
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
