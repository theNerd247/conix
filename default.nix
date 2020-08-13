[ 
  (import ./conix.nix)
  (import ./meta.nix)
  (import ./git.nix)
  (import ./table.nix)
  (import ./markdown.nix)
  (import ./codeSnippets.nix)
  (import ./design)
] 
++ 
(import ./builder)
++
[ (import ./eval.nix) ]
