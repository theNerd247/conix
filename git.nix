conix: { lib = rec
  { git =
    rec
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "9174a55d9c7f43038996ec8c4790ed44d598a8d1";
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
