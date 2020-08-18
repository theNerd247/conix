(import <nixpkgs> { overlays = (import ./default.nix); }).conix.build
(conix: { documentation = with conix.lib;
  dir "conix-docs" 
    [ (withMarkdownFile "docs" htmlFile refDocs)
      (withMarkdownFile "readme" htmlFile docs.readme)
    ];
})
