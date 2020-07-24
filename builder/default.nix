self: super:

(builtins.foldl' super.lib.composeExtensions {}
  [ 
    (import ./markdown.nix)
    (import ./pdf.nix) 
  ] 
) self super;
