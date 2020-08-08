((import <nixpkgs>) { overlays = import ../default.nix; }
).conix.build.htmlFile "design" (conix: conix.foldMapModules (f: f conix) 
  [ (import ./goals.nix)
    (import ./main.nix)
  ]
)
