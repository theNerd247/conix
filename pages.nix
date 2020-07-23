self: super:

{ conix = (super.conix or {}) //
  rec
  { 
    newModule = text: { inherit text; };

    isPage = x: x ? text;

    textModule_ = path: text:
      setPageAt path (newModule text);

    textWith = path: f: modules: 
      let 
        text = f modules;
      in
        { modules = textModule_ path text; inherit text; };

    text = path: text: textWith path (_: text);

    t = pureModule;

    textsWith = path: f: modules:
      setPageFromModule path 
      ( mapModules (nestModules path)
      ( foldModules (f modules)
      )) modules;

    texts = path: textsAndModules: textsWith path (_: textsAndModules);

    # { fst, snd}
    # { modules; text }
    buildPageSet = module: self.lib.fix (pgs: (module pgs).modules);

    # nests all of the pages for a module under the given path
    nestModules = path: modules: setPageAt path modules; 

    # takes the text produced by a module and creates text page and
    # merges it into the current pages. The text does not change.
    #
    # Path -> Module Text -> Module Text
    # Text -> Module Text
    setPageFromModule = path: m: bindModule m (text path); 

    mergeModules = modulesA: modulesB: modules: 
      let
        modulesAndTextA = modulesA modules;
        modulesAndTextB = modulesB modules;
      in
        { modules = mergePages modulesAndTextA.modules modulesAndTextB.modules;
          text = modulesAndTextA.text + modulesAndTextB.text;
        };

    mergePages = self.lib.attrsets.recursiveUpdate;

    setPageAt = self.lib.attrsets.setAttrByPath;

    emptyModule = _: { modules = {}; text = ""; };

    pureModule = text: _: { modules = {}; inherit text; };

    pagesModule = modules: _: { inherit modules; text = ""; };

    mapModules = f: module: modules:
      let
        pagesAndText = module modules;
      in
        { modules = f pagesAndText.modules; text = pagesAndText.text; };

    bindModule = module: f: modules:
      let
        pagesAndText = module modules;
        res = f pagesAndText.text modules;
      in
        { modules = mergePages pagesAndText.modules res.modules; text = res.text; };

    setAt = path: val: pagesModule (setPageAt path val); 

    foldModules = builtins.foldl' mergeModules emptyModule;

    foldMapModules = f: builtins.foldl' (m: x: mergeModules m (f x)) emptyModule;

    buildPages = modules: buildPageSet (foldModules modules); 

    # foldl for recursive attribute sets with paths being sent to a handler;
    # TODO: move this to a util file
    recAttrFold = pred: f: initB:
      let
          # If true recAttrFold will NOT recurse into a nested attribute set.
          # (AttrSet -> Bool)  
          # Fold handler. 
          #  * `b` is the current final value, `rev
          #  * `ReversedPath` is the path from the top of the attribute set down to the value being evaluated in reverse order.
          #    for example: when the y value is passed to the handler where ({ x = { y = 3; }; }) the path will be [ "y" "x" ].
          #    this is so the handler can easily grab the "current" attribute name via builtins.head instead of a more
          #    complex function to grab the last element in a list.
          #  * `Either a b` is either a leaf value in the attribute set OR the
          #    result after recursing into a nested attribute set (assuming the
          #    predicate returns false)
          # -> (b -> ReversedPath -> Either a b -> b) 
          # The initial fold value
          # -> b 
          # The attribute set to fold over
          # -> AttrSet a 
          # -> b
          recAttrFold_ = init: attrSet:
            let
              recF = {b, path}: name: 
                let
                  p = [name] ++ path; 
                  v_ = attrSet."${name}";
                  v = if builtins.isAttrs v_ && ! pred v_ then recAttrFold_ { b = init.b; path = p; } v_ else v_;
                in
                  { b = f b p v; inherit path; };
            in
              (builtins.foldl' recF init (builtins.attrNames attrSet)).b;
      in
        recAttrFold_ { b = initB; path = []; };
  };
}
