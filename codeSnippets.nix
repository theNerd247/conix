conix: { lib = rec
  { 
    snippet 
      # String -> String -> String -> Module
      = language: code: output:
      let
        text = ''
          ```${language}
          ${code}

          ```
          output:

          ```
          ${output}
          ```
          '';
      in
        { inherit text;
          inherit code;
          inherit language;
          inherit output;
        };

    # 1. Cache the given nix code in the store
    # 2. And then evaluate the file.
    cacheAndEvalNix
      # String -> (FilePath -> String) -> String -> String
      = name: evalFile: code:
        let
          file = conix.pkgs.writeText "${name}.nix" code;
        in
          evalFile file;

    # This creates a string from a file that is assumed to contain 
    # nix code and evaluates to a pure nix expression.
    #
    # NOTE: this may be a proper solution to evaluting arbitrary nix expressions.
    # however it will not work until https://github.com/Nixos/nix/pulls/3205 becomes
    # a widespread solution.
    #
    #conix.pkgs.runCommandLocal "${name}-stdout" { buildInputs = [ self.nix ]; } ''
    #  ${self.nix}/bin/nix-instantiate --eval ${file} | tee $out
    #'';
    evalPureNixExpr 
      # FilePath -> String
      = fp: "${printNixVal (import fp)}";

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

    docs.nixSnippetWith.docstr = ''
      Create a module using the given nix snippet code and
      the evaluated result.
     
      The text is markdown (see snippet for the template)
    '';
    docs.nixSnippetWith.todo = [
      ''
      This fails in an stack overflow / infinite recursion issue if:

        * the code is importing conix via a fetch git (using `./git.nix`)
        * and we're building the conix documentation.

        For example the `readme/sample.nix` works on its own, however if its
        text is passed in as the `code` argument inside of the readme derivation
        we get infinite recursion.
      ''
    ];
    docs.nixSnippetWith.type = "Name -> String -> Module";
    nixSnippetWith = name: code: evalNixFilePath:
      let
        module = snippet "nix" code 
          (cacheAndEvalNix name evalNixFilePath code); 
      in
        { ${name} = module; } // (conix.lib.text module.text);

    nixSnippet = name: code: 
      nixSnippetWith name code evalPureNixExpr;

    evalGitCmd
      = name: fp:
        let 
          r = conix.pkgs.runCommandLocal name { buildInputs = [ conix.pkgs.git ]; } ''
           ${builtins.readFile fp} | tee $out
          '';
        in
          "${builtins.readFile r}";

    gitCmd 
      = name: code:
        { ${name} = { text = cacheAndEvalNix name evalGitCmd code; }; }; 
  };
}
