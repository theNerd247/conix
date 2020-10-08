[ (self: super: 
  { conix = 
    let
      E = import ./eval.nix self;
      C = import ./content.nix self;
    in
      { eval = E.eval; 
        run = E.run;
        lib = C;
      };
  }
)]
