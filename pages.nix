self: super:

{ conix = (super.conix or {}) //
  rec
  { 
    newModule = text: { inherit text; };

    isPage = x: x ? text;

    textModule_ = path: text:
      self.lib.attrsets.setAttrByPath path (newModule text);

    textWith = path: f: modules: 
      let 
        text = f modules;
      in
        { modules = textModule_ path text; inherit text; };

    text = path: text: modules: textWith path (_: text) modules;

    buildPageSet = module: self.lib.fix (pgs: (module pgs).modules);

    mergeModules = modulesA: modulesB: modules: 
      let
        modulesAndTextA = modulesA modules;
        modulesAndTextB = modulesB modules;
      in
        { modules = self.lib.attrsets.recursiveUpdate modulesAndTextA.modules modulesAndTextB.modules;
          text = modulesAndTextA.text + modulesAndTextB.text;
        };

    emptyModule = _: { modules = {}; text = ""; };

    pureModule = text: _: { modules = {}; inherit text; };

    pageModule = modules: _: { inherit modules; text = ""; };

    setAt = path: val: pageModule (self.lib.attrsets.setAttrByPath path val); 

    collectModules = builtins.foldl' mergeModules emptyModule;

    buildPages = modules: buildPageSet (collectModules modules); 

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
