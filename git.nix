conix: { lib = rec
  { git =
    rec
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "ded712c8d4b7dae38e2b03e1bfb079e8c1d12d95";
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
