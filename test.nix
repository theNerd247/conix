let
  pkgs = import <nixpkgs> { overlays = (import ./conix.nix); };
  pages = pkgs.conix.page [ "foo" ]
    ''
      # Test title

      test text
    '';
in
  pkgs.conix.build.pdf "foob"  [ pages.foo ]
