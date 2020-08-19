conix: { lib = rec
  { git =
    rec
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "b60572b2ed4c6037aab48e00e8f50723bf00b1b7";
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
