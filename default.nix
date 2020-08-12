[ 
  (import ./conix.nix)
  (import ./meta.nix)
  (import ./table.nix)
] 
++ 
(import ./builder)
++
[ (import ./eval.nix) ]
