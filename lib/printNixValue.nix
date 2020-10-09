pkgs:

rec
{
  docs.printNixVal.docstr = ''
    Pretty print a pure nix-value. 

    NOTE: do not call this function on a derivation as it will segfault.
    '';
  docs.printNixVal.type = "a -> String";
  printNixVal = e:
    if builtins.isAttrs e then printAttrs e
    else if builtins.isList e then printList e
    else if builtins.isNull e then "null"
    else if builtins.isFunction e then "<lambda>"
    else builtins.toString e;

  printAttrs = e:
    let
      printElem = name: value:
        "${name} = ${ printNixVal value };";

      printElems = 
        builtins.concatStringsSep " "
          (pkgs.lib.attrsets.mapAttrsToList printElem e);
    in
      "{ ${printElems} }";

  printList = e:
    let
      printElems = builtins.concatStringsSep " "
        (builtins.map printNixVal e);
    in
      "[ ${printElems} ]";

}
