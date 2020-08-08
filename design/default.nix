((import <nixpkgs>) { overlays = import ../default.nix; }
).conix.build.htmlFile "design" (conix: conix.foldModules 
  [ ((import ./goals.nix) conix)
    ((import ./main.nix) conix)
  ]
)
