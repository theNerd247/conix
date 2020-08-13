self: super:

with super.conix;

{ conix = (super.conix or {}) //
  rec
  { git =
    rec
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "be7c436367eb7ed36b306aa3ba983cb73e8e7dba"
      rev = "v0.1.0-api"
      text = ''
        { url = ${url};
          rev = ${rev};
          ref = ${ref};
        }
      '';
    };

    lib = super.conix.extendLib super.conix.lib (x:
      { inherit git; }
    );
  };
}
