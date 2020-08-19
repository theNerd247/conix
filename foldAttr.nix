conix: { lib = 
let inherit (conix.pkgs.lib.attrsets) mapAttrs; in
rec { 

  docs.foldAttrsIxCond.docstr = ''
    This is just like `foldAttrsCond` except the function to convert leaf
    values into final values also takes in the path from the top of the
    attribute set for that leaf value.
    '';
  docs.foldAttrsIxCond.type = "((AttrSet e ) -> Bool) -> (a -> Path -> b) -> (AttrSet b -> b) -> AttrSet a -> Path -> b";
  foldAttrsIxCond = pred: onLeaf: mergeLeafs: set:
    foldAttrsCond 
      pred 
      onLeaf 
      (fs: path: mergeLeafs (mapAttrs (name: f: f (path ++ [name])) fs))
      set
      [];

  docs.foldAttrsCond.docstr = ''
    Fold an attribute set down while allowing for attribute sets to be a leaf value. 

    The first function returns true if the given attribute set is a leaf value.
    The second function maps leaf values to final values.
    The third function returns a combined final value from the final values of the lower branches.

    For example, to sum the leaf values in an attribute set where a leaf is either a nix value
    or attribute set containing "stop" as an attribute is:

    ```nix
    countLeaves = foldAttrsCond 
      # An attribute set is a leaf if it contains "stop" as an attribute.
      (s: s ? stop) 
      # return the value 1 for each leaf. We don't need the actual value to compute the result.
      (_: 1)        
      # countMap is a flat attribute set containing the previously counted branches.
      (countMap: builtins.foldl' (sum: count: sum + count) 0 (builtins.attrValues countMap));

    # This should return 5.
    nleaves = countLeaves { a = { b = "b"; c = "c"; }; d.e.f = "f"; g = { h = { stop = 2; }; i = 7; }; };
    '';
  docs.foldAttrsCond.type = "(a -> Bool) -> (a -> b) -> (AttrSet b -> b) -> AttrSet a -> b";
  foldAttrsCond = pred: onLeaf: mergeLeafs:
    let
      # (a | AttrSet b) -> b
      alg = x: if (! builtins.isAttrs x) || (pred x) then onLeaf x else mergeLeafs x;

      # (a -> b) -> (a | AttrSet a) -> b
      fmap = f: x:
        if (! builtins.isAttrs x) || (pred x)
        then x else mapAttrs (name: f) x;

      # AttrSet a -> b
      cata = x: alg (fmap cata x);
    in
      cata;
}; }
