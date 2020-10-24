conix: with conix;

rec
{
  module = docstr: r:
    [ docstr
      (foldAttrsIxCond
        isTyped
        (x: x)
        builtins.attrValues
        r
      )
    ];

  expr = type: docstr: _expr: p:
    let
      path = builtins.concatStringsSep "." p;
    in
      [ ''```haskell
        ''path " :: " type ''


        ```

        ''
        docstr ''

        
        ''

        (_tell { ${path} = _expr; })
      ];
} // conix
