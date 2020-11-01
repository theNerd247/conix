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

  # User API that ./conix.nix depends on
  pandoc = _pandocType: _pandocArgs: _buildInputs: _fileName: _next:
    _file
    { _mkFile = txt: 
        pkgs.runCommand "${_fileName}.${_pandocType}" { buildInputs = [ pkgs.pandoc ] ++ _buildInputs; }
        ''
        ${pkgs.pandoc}/bin/pandoc -s -o $out ${_pandocArgs} ${pkgs.writeText "${_fileName}.md" txt}
        '';
      inherit _next;
    };

  html = _fileName: pandoc "html" "" [] _fileName;

  pdf = _fileName: pandoc "pdf" "" [pkgs.texlive.combined.scheme-small] _fileName;

  markdown = _fileName: _next: _file 
    { _mkFile = pkgs.writeText "${_fileName}.md"; 
      inherit _next;
    };

  meta = _data: [ "---\n" (intersperse "\n" _data) "\n---\n" ];

  intersperse = s:
    builtins.foldl' 
      ({skip, as}: a:
        { skip = false;
          as = if skip then as ++ [a] else as ++ [s a];
        }
      )
      {skip=true; as = [];}
  ;

  css = localPath: [ "css: " (pathOf localPath) ];

  pathOf = localPath:
    [ (_local localPath)
      "./${builtins.baseNameOf localPath}"
    ];

  conix = import ./meta.nix;

  ask = _ask;

  htmlModule = name: x:
    html name [ (meta (css ../static/latex.css)) x ];

  module = docstr: r:
    [ docstr
      (F.foldAttrsIxCond
        T.isTyped
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

        (_tell (pkgs.lib.attrsets.setAttrByPath p _expr))
        (_tell (pkgs.lib.attrsets.setAttrByPath (["_docs"] ++ p) { inherit type docstr; }))
      ];

  docs.liftNixValue.docstr = x: with x; [''
  Parses expressions written in the Nix host language
  into the Conix eDSL. The follow conversions are performed:

  ''(table
    [ "Nix Expression"   "Conix Expression"]
    [ ["<string>"        "`text`"]
      ["<path>"          "`local`"]
      ["<t:attrset>"     "`[(tell t) (liftNixVal x | forall x in leaves of t)]`"]
      ["<func>"          "`using`"]
      ["<list>"          "`merge`"]
    ]
  )''


  _Important_: This function is NOT lazy because it uses Nix's `typeOf` function
  which forces WHNF evaluation. I'm still working on a workaround that doesn't
  affect the users's syntax but with no current avail. I think the best long
  term solution would to push an upstream change into Nix's evaluator to make
  this function lazy.
  ''];
   
  liftNixValue = mkHostLangParser attrsetToContent;

  mkHostLangParser = parseAttrSets: t: fmap liftNixValue (
           if T.isTyped t           then t 
      else if builtins.isPath t     then _local t
      else if builtins.isAttrs t    then (parseAttrSets t)
      else if builtins.isFunction t then _using t
      else if builtins.isList t     then _merge t
      else _text t
    );

  attrsetToContent = t: _merge 
    [ (_tell t)
      (F.foldAttrsCond
        T.isTyped
        liftNixValue
        (vals: _merge (builtins.attrValues vals)) 
        t
      )
    ];

  # Internals

  # Markup Constructors
  docs._tell.type = "{ _data :: AttrSet }  -> ContentF a";
  _tell = T.typed "tell";

  docs._using.type = "(AttrSet -> a) -> ContentF a";
  _using = T.typed "using";

  # NOTE: for now we'll use the final encoding of documents. However,
  # In the future it might be useful to use the inital encoding
  # (like a copy of the Pandoc AST).
  docs.text.type = "String -> ContentF a";
  _text = T.typed "text";

  # File System Constructors
  docs._file.type = "{_fileName :: FileName, _next :: a} -> ContentF a";
  _file = T.typed "file";

  docs._dir.type = "{ _dirName :: DirName, _next :: a} -> ContentF a";
  _dir = T.typed "dir";

  docs._local.type = "FilePath -> ContentF a";
  _local = T.typed "local";

  docs._merge.type = "[a] -> ContentF a";
  _merge = T.typed "merge";

  docs._indent.type = "{ _nSpaces :: Natural, _next :: a } -> ContentF a";
  _indent = T.typed "indent";

  docs._ask.type = "a -> ContentF a";
  _ask = T.typed "ask";

  docs._nest.type = "PathString -> a -> ContentF a";
  _nest = T.typed "nest";

  fmapMatch = f:
    { 
      tell   = _data: _tell _data;
      text   = x: _text x;
      local  = x: _local x;
      file   = {_mkFile, _next}: _file { inherit _mkFile; _next = f _next; };
      dir    = {_dirName, _next}: _dir { inherit _dirName; _next = f _next; };
      indent = {_nSpaces, _next}: _indent { inherit _nSpaces; _next = f _next; };
      merge  = xs: _merge (builtins.map f xs);
      using  = g: _using (x: f (g x));
      ask    = x: _ask (f x);
      nest   = {_path, _next}: _nest { inherit _path; _next = f _next; };
    };

  fmap = T.matchWith fmapMatch;
} // T // F
