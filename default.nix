[ 
  (import ./conix.nix)
  (import ./meta.nix)
  (import ./table.nix)
  (import ./markdown.nix)
  (import ./codeSnippets.nix)
] 
++ 
(import ./builder)
++
[ (import ./eval.nix) ]
