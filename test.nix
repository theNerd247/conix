let
  pkgs = import <nixpkgs> { overlays = (import ./conix.nix); };
  foo = pkgs.conix.textPage [ "foo" ]
    ''
      # Test title

      test text
    '';

  pages = pkgs.conix.buildPages foo;
in
  pkgs.conix.build.pdf "foob"  [ pages.foo ]
