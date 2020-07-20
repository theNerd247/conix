self: super:

{ conix = (super.conix or {}) //
  rec
  { newModule = text: { inherit text; };
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

    collectModules = builtins.foldl' mergeModules emptyModule;

    buildPages = modules: buildPageSet (collectModules modules); 
  };
}
