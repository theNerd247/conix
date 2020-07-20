let
  pkgs = import <nixpkgs> { overlays = (import ./conix.nix); };
  foo = pkgs.conix.text [ "foo" ]
    ''
      # Test title

      test text
    '';

  bar = pkgs.conix.textWith [ "bar" ] 
    (pages: ''
      # Bar page

      Foo content

      ${pages.foo.text} 
    '');
    

  pages = pkgs.conix.buildPages [foo bar];
in
  pkgs.conix.build.pdf "foob"  [ pages.bar ]
