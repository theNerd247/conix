conix: { lib = rec
  { git =
    rec
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "30e750a6eb3acc5644a01c0d1759f19ac0e0e264";
      ref = "v0.1.0-api";
      text = ''
        { url = "${url}";
          rev = "${rev}";
          ref = "${ref}";
        }
        '';
    };
  };
}
