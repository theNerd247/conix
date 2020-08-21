conix: { lib = rec
  { git =
    rec
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "7f62186d4f3da6f85341f715ec73dceed3958cbb";
      ref = "travis";
      text = ''
        { url = "${url}";
          rev = "${rev}";
          #ref = "${ref}";
        }
        '';
    };
  };
}
