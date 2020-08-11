((import <nixpkgs>) { overlays = import ../default.nix; }
).conix.build.htmlFile "design" (conix: conix.texts [] [ 
  ((import ./goals.nix) conix)
  ((import ./core.nix) conix)
])
