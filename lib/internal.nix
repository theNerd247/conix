# This module defines the core functor defining the conix eDSL I aim to make
# the constructors as orthoganal as possible and any convenience / user facing
# constructors are defined in ./conix.nix.
pkgs:

let
  T = import ./types.nix;
  F = import ./foldAttr.nix pkgs;
in

rec
{ 
  #     (Content -> Content)
  #  -> { <path> :: { fst :: Content, snd :: Content } } 
  #  -> Content
  # Where 
  #  * `fst` = expr
  #  * `snd` = documentation
  module = f: exprSet:
    let
      exprsAndDocs = 
        F.foldAttrsIxCond
        T.isTyped
        (x: x)
        (es: with builtins; 
          foldl' 
            ({fst, snd}: x: 
              { fst = fst ++ [x.fst]; snd = snd ++ x.snd; }
            )
            { fst = []; snd = []; } 
            (attrValues es)
        )
        exprSet;
    in
      exprsAndDocs.fst ++ [ (f exprsAndDocs.snd) ];

  expr = type: docstr: x: p:
    let
      _path = builtins.concatStringsSep "." p;
      exprSet = pkgs.lib.attrsets.setAttrByPath p x;
      docsRefPath = ["docs"] ++ p;
    in
      { fst = _expr exprSet;
        snd = [
          ''<a name="docs.${_path}"></a>
          ''(_ref { _path = docsRefPath; _next = [
            ''```haskell
            ''_path " :: " type 
          ];})''


          ```

          ''
          docstr ''

          
          ''
        ];
      };

  I.docs.liftNixValue.docstr =
    [ 
      ["\\<strings\\>, \\<numbers\\>, \\<booleans\\>" "Write the text (or multiline text) to the current file"]
      ["././foo/bar.png" "Include the given file in the current directory. No text is produced."]
      ["{ name = \\<content\\>; }" "Add \\<content\\> to `data.\${name}` and create a reference in `refs.\${name}`. \\<content\\> is also evaluated as if the braces weren't there."]
      ["[\\<content\\> \\<content\\> ...]" "Concatenate the text of the \\<content\\>s and merge the derivations produced by \\<content\\>s into a directory"]
      ["conix: with conix; \\<content\\>"  { conixFunctionSyntax = "Brings `data`, `refs`, and the conix library into \\<content\\>'s scope."; }]
    ]
    ;
   
  liftNixValue  = t: fmap liftNixValue (
           if T.isTyped t           then t 
      else if builtins.isPath t     then _local t
      else if builtins.isAttrs t    then (attrsetToContent t)
      else if builtins.isFunction t then _using t
      else if builtins.isList t     then _merge t
      else _text t
    );

  attrsetToContent = t: _merge 
    [ (_tell t)
      (F.foldAttrsIxCond
        T.isTyped
        (t: _path: _ref { inherit _path; _next = liftNixValue t; })
        (vals: _merge (builtins.attrValues vals)) 
        t
      )
    ];

  # Internals

  # Markup Constructors
  I.docs._tell.type = "AttrSet -> ContentF a";
  _tell = T.typed "tell";

  I.docs._using.type = "(AttrSet -> a) -> ContentF a";
  _using = T.typed "using";

  # NOTE: for now we'll use the final encoding of documents. However,
  # In the future it might be useful to use the inital encoding
  # (like a copy of the Pandoc AST).
  I.docs._text.type = "String -> ContentF a";
  _text = T.typed "text";

  # File System Constructors
  I.docs._file.type = "{_fileName :: FileNameString, _mkFile :: (Text -> Derivation), _next :: a} -> ContentF a";
  _file = T.typed "file";

  I.docs._dir.type = "{ _dirName :: DirName, _next :: a} -> ContentF a";
  _dir = T.typed "dir";

  I.docs._local.type = "FilePath -> ContentF a";
  _local = T.typed "local";

  I.docs._merge.type = "[a] -> ContentF a";
  _merge = T.typed "merge";

  I.docs._modtxt.type = "{ _modify :: Text -> Text, _next :: a } -> ContentF a";
  _modtxt = T.typed "modtxt";

  I.docs._ask.type = "a -> ContentF a";
  _ask = T.typed "ask";

  I.docs._use.type = "a -> ContentF a";
  _use = T.typed "use";

  I.docs._nest.type = "{ _path :: AttrPathString, _next :: a} -> ContentF a";
  _nest = T.typed "nest";

  I.docs._ref.type = "{ _path :: AttrPathList, _next :: a} -> ContentF a";
  _ref = T.typed "ref";

  I.docs._link.type = "a -> ContentF a";
  _link = T.typed "link";

  I.docs._expr.type = "AttrSet -> ContentF a";
  _expr = T.typed "expr";

  fmapMatch = f:
    { 
      tell   = x: _tell x;
      text   = x: _text x;
      local  = x: _local x;
      expr   = x: _expr x;
      file   = {_fileName, _mkFile, _next}: _file { inherit _mkFile _fileName; _next = f _next; };
      dir    = {_dirName, _next}: _dir { inherit _dirName; _next = f _next; };
      modtxt = {_modify, _next}: _modtxt { inherit _modify; _next = f _next; };
      merge  = xs: _merge (builtins.map f xs);
      using  = g: _using (x: f (g x));
      ask    = x: _ask (f x);
      use    = x: _use (f x);
      nest   = {_path, _next}: _nest { inherit _path; _next = f _next; };
      ref    = {_path, _next}: _ref { inherit _path; _next = f _next; };
      link   = x: _link x;
    };

  fmap = T.matchWith fmapMatch;
} // T // F
