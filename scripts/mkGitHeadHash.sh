#!/usr/bin/env nix-shell 
#! nix-shell -p git -i bash

cat > git.nix <<HERE
conix: { lib = rec
  { git =
    rec
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "$(git rev-parse HEAD)";
      ref = "$(git branch --show-current)";
      text = ''
        { url = "\${url}";
          rev = "\${rev}";
          ref = "\${ref}";
        }
        '';
    };
  };
}
HERE