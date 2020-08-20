conix: { lib = rec
  { git =
    rec
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "86844bbf917870f311a225bc38c60ae535a3ad76";
      ref = "travis";
      text = ''
        { url = "${url}";
          rev = "${rev}";
          ref = "${ref}";
        }
        '';
    };
  };
}
