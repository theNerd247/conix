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
  pandoc = _pandocType: _pandocArgs: _buildInputs: _fName: _next:
    _file
    (rec
    { 
      inherit _next ;
      _fileName = "${_fName}.${_pandocType}";
      _mkFile = txt: 
        pkgs.runCommand _fileName { buildInputs = [ pkgs.pandoc ] ++ _buildInputs; }
        ''
        ${pkgs.pandoc}/bin/pandoc -s -o $out ${_pandocArgs} ${pkgs.writeText "${_fName}.md" txt}
        '';
    });

  html = _fileName: pandoc "html" "" [] _fileName;

  pdf = _fileName: pandoc "pdf" "" [pkgs.texlive.combined.scheme-small] _fileName;

  markdown = _fName: textfile "${_fName}.md";

  textfile = _fName: _next: _file 
    rec
    { 
      inherit _next;
      _mkFile = pkgs.writeText _fileName; 
      _fileName = _fName;
    };

  meta = x: [ "\n\n---\n" (intersperse "\n" x) "\n---\n\n" ];

  intersperse = s: xs:
    (builtins.foldl' 
      ({skip, as}: a:
        { skip = false;
          as = if skip then as ++ [a] else as ++ [s a];
        }
      )
      {skip=true; as = [];}
      xs
    ).as;

  css = localPath: [ "css: " (pathOf localPath) ];

  pagetitle = title: [ "pagetitle: " title ];

  pathOf = localPath:
    [ (_local localPath)
      "./${builtins.baseNameOf localPath}"
    ];

  conix = import ./meta.nix;

  ask = _ask;

  ref = _path: _next:
    _ref { inherit _path _next; };

  link = _link;

  modtxt = _modify: _next:
    _modtxt { inherit _modify _next; };

  conixCss = ../static/latex.css;

  tutorialSnippet = fileName: refName: content:
    [ 
      ''```nix
      ''{ tutorials.${refName} = textfile fileName content; }''
      
      ```
      ''
    ];

  module = docstr: r:
    [ docstr
      (F.foldAttrsIxCond
        T.isTyped
        (x: x)
        builtins.attrValues
        r
      )
    ];

  expr = type: docstr: x: p:
    let
      path = builtins.concatStringsSep "." p;
    in
      [ ''```haskell
        ''path " :: " type ''


        ```

        ''
        docstr ''

        
        ''

        (_expr (pkgs.lib.attrsets.setAttrByPath p x))
      ];

  docs.liftNixValue.docstr = x: with x; [''
  Parses expressions written in the Nix host language
  into the Conix eDSL.

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
      (F.foldAttrsIxCond
        T.isTyped
        (t: path: ref path (liftNixValue t))
        (vals: _merge (builtins.attrValues vals)) 
        t
      )
    ];

  # Internals

  # Markup Constructors
  docs._tell.type = "AttrSet -> ContentF a";
  _tell = T.typed "tell";

  docs._using.type = "(AttrSet -> a) -> ContentF a";
  _using = T.typed "using";

  # NOTE: for now we'll use the final encoding of documents. However,
  # In the future it might be useful to use the inital encoding
  # (like a copy of the Pandoc AST).
  docs._text.type = "String -> ContentF a";
  _text = T.typed "text";

  # File System Constructors
  docs._file.type = "{_fileName :: FileNameString, _mkFile :: (Text -> Derivation), _next :: a} -> ContentF a";
  _file = T.typed "file";

  docs._dir.type = "{ _dirName :: DirName, _next :: a} -> ContentF a";
  _dir = T.typed "dir";

  docs._local.type = "FilePath -> ContentF a";
  _local = T.typed "local";

  docs._merge.type = "[a] -> ContentF a";
  _merge = T.typed "merge";

  docs._modtxt.type = "{ _modify :: Text -> Text, _next :: a } -> ContentF a";
  _modtxt = T.typed "modtxt";

  docs._ask.type = "a -> ContentF a";
  _ask = T.typed "ask";

  docs._nest.type = "{ _path :: AttrPathString, _next :: a} -> ContentF a";
  _nest = T.typed "nest";

  docs._ref.type = "{ _path :: AttrPathString, _next :: a} -> ContentF a";
  _ref = T.typed "ref";

  docs._link.type = "a -> ContentF a";
  _link = T.typed "link";

  docs._expr.type = "AttrSet -> ContentF a";
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
      nest   = {_path, _next}: _nest { inherit _path; _next = f _next; };
      ref    = {_path, _next}: _ref { inherit _path; _next = f _next; };
      link   = x: _link x;
    };

  fmap = T.matchWith fmapMatch;
} // T // F
