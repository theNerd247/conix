conix: { lib = rec
  { git =
    rec
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "1f8a7e9e96b4709bd08c870be8ff27023500be31";
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
