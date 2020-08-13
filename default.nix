[ 
  (import ./conix.nix)
  (import ./meta.nix)
  (import ./table.nix)
  (import ./codeSnippets.nix)
] 
++ 
(import ./builder)
++
[ (import ./eval.nix) ]
