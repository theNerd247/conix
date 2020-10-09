# This is an internal EDSL for creating Nix Expressions that
# are documented. It can be exported to users.
let
  T = import ./types.nix;
in
{
  _expr = type: docstr: expr: 
    T.typed "expr" { inherit type docstr expr; };

  _module = T.typed "module";

  _using = T.typed "using";

  # This is the self-consuming expression that documents
  # the above expressions and produces the public api for
  # this module.
  docs = _module { 
    expr = _expr 
      "TypeString -> DocString -> NixExpr -> Module"
      "Construct a single, documented nix expression"
      _expr;

    module = _expr "{ Name :: Module } -> Module" ''
        Create a named collection of modules. This is akin to creating a nix
        expression in a file that is an attribute set that defines an API to
        be used.

        Traditional nix:

        ```
        { 
          # Create a Zero expression
          # zero :: Nat
          zero = 0;

          # Create a Succ expression
          # succ :: Nat -> Nat
          succ = x: x+1;
        }
        ```

        Using Module api:

        ```
        with (import ./module.nix);

        module
        { 
          zero = expr "Nat" "Create a Zero expression" 0;
          succ = expr "Nat -> Nat" "Create a Succ expression" (x: x+1);
        }
        ```
        Notice how the doc strings and types are comments in the code.  A
        separate nix parser and special syntax would be required to parse
        special comments to generate the documentation. With this library
        no external tools are required.
        ''
      _module;

    using = _expr "(Pkgs -> Module) -> Module" ''
      Create a module that depends on the toplevel <nixpkgs> expression.
      This is akin to writing expressions such as:

      ''
      _using;
  };
}
