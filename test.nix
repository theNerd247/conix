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

      We have ${builtins.toString pages.baz.joe} baz joes;

      Foo content

      ${pages.foo.text} 
    '');
    

  baz = pkgs.conix.setAt [ "baz" "joe" ] 3;

  pages = pkgs.conix.buildPages [foo bar baz];
in

rec
{ x = pkgs.conix.setLinks { bob = { content = "foo"; a = { content = "bar"; }; }; b = { content = "boob"; }; };  
  a = { a = 1; b = { c = 2; d = 4; }; };
  #pkgs.lib.attrsets.recursiveUpdate a

}
