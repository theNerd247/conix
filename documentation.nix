(import <nixpkgs> { overlays = (import ./default.nix); }).conix.build
(conix: { documentation = with conix.lib;
  copyJoin "conix-docs" 
    [ refDocs
      (markdownFile "readme" docs.readme)
    ];
})
