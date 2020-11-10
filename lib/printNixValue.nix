internalLib: with internalLib; module

rec
{

  printNixVal = expr 
    "a -> String"
    ''
    Pretty print a pure nix-value. 

    _NOTE_: do not call this function on a derivation as it will segfault.
    ''
    (let
        printAttrs = e:
          let
            printElem = name: value:
              "${name} = ${ printVal value };";

            printElems = 
              builtins.concatStringsSep " "
                (pkgs.lib.attrsets.mapAttrsToList printElem e);
          in
            "{ ${printElems} }";

        printList = e:
          let
            printElems = builtins.concatStringsSep " "
              (builtins.map printVal e);
          in
            "[ ${printElems} ]";

        printVal  = e: with builtins;
          if      isAttrs e then printAttrs e
          else if isList e then printList e
          else if isNull e then "null"
          else if isFunction e then "<lambda>"
          else if isString e then "\"${e}\""
          else toString e;
      in
        printVal
    );
}
