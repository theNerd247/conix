self: super:

{ conix = (super.conix or {}) // rec 
  { 
    snippet 
      # String -> String -> String -> AttrSet
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
          file = super.writeText "${name}.nix" code;
        in
          evalFile file;

    # This creates a string from a file that is assumed to contain 
    # nix code and evaluates to a pure nix expression.
    #
    # NOTE: this may be a proper solution to evaluting arbitrary nix expressions.
    # however it will not work until https://github.com/Nixos/nix/pulls/3205 becomes
    # a widespread solution.
    #
    #super.runCommandLocal "${name}-stdout" { buildInputs = [ self.nix ]; } ''
    #  ${self.nix}/bin/nix-instantiate --eval ${file} | tee $out
    #'';
    evalPureNixExpr 
      # FilePath -> String
      = fp: "${builtins.toString (import fp)}";

    # Create a module using the given nix snippet code and the evaluated
    # result.
    #
    # The text is markdown (see snippet for the template)
    nixSnippet = name: code: 
      snippet "nix" code (cacheAndEvalNix name evalPureNixExpr code);

    nixSnippetWith = name: code: evalNixFilePath:
      snippet "nix" code (cacheAndEvalNix name evalNixFilePath code);

    lib = super.conix.extendLib super.conix.lib (x: 
      { inherit
        snippet
        nixSnippet
        nixSnippetWith;
      }
    );
  };
}
