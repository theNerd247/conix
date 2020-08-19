conix: { lib = rec
  { 
    docs.snippet.docstr = ''
      Create a module whos text is a code snippet with some evaluated output.
      If no output is provided then it's codeblock is omitted.
    '';
    docs.snippet.type = "LanguageString -> CodeString -> OutputString -> Module";
    snippet 
      = language: code: output:
      let
        text = ''
          ```${language}
          ${code}

          ```
          ${if output == "" || output == null 
            then "" 
            else
            ''
            ```
            ===>
            ${output}
            ```
            ''
          }
          '';
      in
        { inherit text;
          inherit code;
          inherit language;
          inherit output;
        };

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
            (conix.pkgs.lib.attrsets.mapAttrsToList printElem e);
      in
        "{ ${printElems} }";

    printList = e:
      let
        printElems = builtins.concatStringsSep " "
          (builtins.map printNixVal e);
      in
        "[ ${printElems} ]";

    docs.nixSnippet.docstr = ''
      Create a module using the given nix snippet code and
      the evaluated result.
     
      The text is markdown (see snippet for the template)
    '';
    docs.nixSnippet.todo = [
      ''
      This fails in an stack overflow / infinite recursion issue if:

        * the code is importing conix via a fetch git (using `./git.nix`)
        * and we're building the conix documentation.

        For example the `readme/sample.nix` works on its own, however if its
        text is passed in as the `code` argument inside of the readme derivation
        we get infinite recursion.
      ''
    ];
    docs.nixSnippet.type = "Name -> String -> Module";
    nixSnippet = name: code: evalNixFilePath:
      let
        nixFile = conix.pkgs.writeText "${name}.nix" code;
      in
        conix.lib.set name (snippet "nix" code "${printNixVal (import nixFile)}");
  };
}
