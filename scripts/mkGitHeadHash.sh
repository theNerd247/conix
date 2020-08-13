#!/usr/bin/env nix-shell 
#! nix-shell -p git -i bash

cat > git.nix <<HERE
self: super:

with super.conix;

{ conix = (super.conix or {}) //
  rec
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

    lib = super.conix.extendLib super.conix.lib (x:
      { inherit git; }
    );
  };
}
HERE
