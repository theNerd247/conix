let 
  conix = (import <nixpkgs> { 
    overlays = import ./default.nix; 
  }).conix;

  docs = conix.evalPages conix.docs;

  design = conix.build.htmlFile
    { name = "design";
      inherit (docs.design) text;
    };

  readme = conix.build.htmlFile
    { name = "readme";
      inherit (docs.readme) text;
    };
in
  { inherit design;
    inherit readme;
  }
