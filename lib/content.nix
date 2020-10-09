pkgs:

let
  T = import ./types.nix;
  F = import ./foldAttr.nix pkgs;
in

# Re-export constructors to build the toplevel api
rec
{ 
  liftNixValue = mkHostLangParser attrsetToContent;

  module = mkHostLangParser attrSetToModule;

  # Main API
  # "Parses" nix values into Content values
  # using mutual recursion
  # a -> Content
  mkHostLangParser = parseAttrSets: t: fmap liftNixValue (
         if T.isTyped t           then t 
    else if builtins.isPath t     then _local t
    else if builtins.isAttrs t    then (parseAttrSets t)
    else if builtins.isFunction t then _using t
    else if builtins.isList t     then _merge t
    else _text t
  );

  attrsetToContent = t: _tell 
    { _data = t; 
      _next = F.foldAttrsCond
        T.isTyped
        liftNixValue
        (vals: _merge (builtins.attrValues vals)) 
        t;
    };

  # Custom parser for generating documentation along side nix modules
  # (attribute sets  that define an API)
  attrSetToModule = F.foldAttrsIxCond
    T.isTyped
    (x: path: with builtins; 
      let
        p = builtins.concatStringsSep "." path;
      in
      if builtins.isList x then 
      _tell 
        { _data = { ${p} = elemAt x 2; };
          _next = 
            [ "```haskell\n${p} :: " (liftNixValue (elemAt x 0)) 
              "\n```\n" 
              (liftNixValue (elemAt x 1)) 
              "\n\n" 
            ];
        }
      else 
        _tell { _data = { ${p} = x; }; _next = _text ""; }
    )
    (vals: _merge (builtins.attrValues vals));

  # Internals

  # Markup Constructors
  docs.content._tell.type = "{ _data :: AttrSet, _next :: a} -> ContentF a";
  _tell = T.typed "tell";

  docs.content._using.type = "(AttrSet -> a) -> ContentF a";
  _using = T.typed "using";

  # NOTE: for now we'll use the final encoding of documents. However,
  # In the future it might be useful to use the inital encoding
  # (like a copy of the Pandoc AST).
  docs.content.text.type = "String -> ContentF a";
  _text = T.typed "text";

  # File System Constructors
  docs.content._file.type = "{_fileName :: FileName, _next :: a} -> ContentF a";
  _file = T.typed "file";

  docs.content._dir.type = "{ _dirName :: DirName, _next :: a} -> ContentF a";
  _dir = T.typed "dir";

  docs.content._local.type = "FilePath -> ContentF a";
  _local = T.typed "local";

  docs.content._merge.type = "[a] -> ContentF a";
  _merge = T.typed "merge";


  docs.content._indent.type = "{ _nSpaces :: Natural, _next :: a } -> ContentF a";
  _indent = T.typed "indent";

  fmapMatch = f:
    { 
      "tell"  = {_data, _next}: _tell { inherit _data; _next = f _next; };
      "text"  = x: _text x;
      "local" = x: _local x;
      "file"  = {_mkFile, _next}: 
        _file { inherit _mkFile; _next = f _next; };
      "dir" = {_dirName, _next}:
        _dir { inherit _dirName; _next = f _next; };
      "indent" = {_nSpaces, _next}:
        _indent { inherit _nSpaces; _next = f _next; };
      "merge" = xs: _merge (builtins.map f xs);
      "using" = g: _using (x: f (g x));
    };

  fmap = T.matchWith fmapMatch;
}
