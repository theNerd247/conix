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

    setLinks = setIf 
      (_: __: isPage) 
      (_: p: x: 
        { "${builtins.head p}" = x // 
          { link = "/" + builtins.concatStringsSep "/" (self.lib.lists.reverseList p); 
          };
        }
      );

    setIf = pred: f:
      recAttrFold
      isPage
      (s: p: x: 
        let
          n = builtins.head p;
        in
          if pred s p x 
          then s // f s p x
          else s // { "${n}" = x; }
      ) {}; 

    # foldl for recursive attribute sets with paths being sent to a handler;
    # TODO: move this to a util file
    recAttrFold = pred: f: initB:
      let
          # (AttrSet -> Bool) -> (b -> ReversedPath -> Either a b -> b) -> b -> AttrSet a -> b
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
