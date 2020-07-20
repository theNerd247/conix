let
  pkgs = import <nixpkgs> { overlays = (import ./conix.nix); };
in
  pkgs.conix.build.pdf "foo" 
  [
    { contents =
      ''
        # A test Page

        some test text
      '';
    }
  ]
