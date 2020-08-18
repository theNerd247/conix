conix: { lib =
  rec
  { git =
    rec
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "c8bc3ae228c3bdc554405587831cd26b4d6b70fa";
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