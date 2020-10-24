x: with x; module  ""

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

        printVal  = e:
          if builtins.isAttrs e then printAttrs e
          else if builtins.isList e then printList e
          else if builtins.isNull e then "null"
          else if builtins.isFunction e then "<lambda>"
          else builtins.toString e;
      in
        (x: data.text (printVal x))
    );
}
