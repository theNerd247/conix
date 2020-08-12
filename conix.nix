let 
  pkgs = import <nixpkgs> {};
in with pkgs;
rec 
{
  fmap_ = g: f: x: g (f x);

  ap_ = g: f: x: g x (f x);

  liftA2_ = h: g: f: ap_ (fmap_ h g) f;

  mergeModule = lib.attrsets.recursiveUpdate;

  pure_ = x: _: x;

  mergeModuleFunc = liftA2_ mergeModule;

  mergeMap_ = f: 
    builtins.foldl' (m: x: mergeModuleFunc m (f x)) (pure_ {});

  merge_ = mergeMap_ (x: x);

  text_ = text: { text = s text; };

  # This is the core function that makes conix work.  It merges the current
  # attribute set and preserves the concatenates the toplevel text values. If
  # `b` is:
  # 
  #  * a string then the `a` has its `text` value concatenated with `b`
  #  * an attribute set then the resulting attribute set has its `text` field
  #  set to `a.text + b.text`.
  #
  # **NOTE:** if `b` is a string then IT MUST NOT CONTAIN INTERPOLATIONS THAT
  # REFER TO RECURSIVE ATTRIBUTE VALUES THIS WILL CAUSE INFINITE RECURSION
  # ERRORS! For example:
  # 
  #   (conix: { favorite = texts_ [ 
  #      "My " 
  #      ({ color = 256; text = "Blue"; })
  #      " color is very ${s conix.favorite.color}"
  #   ];})
  #
  # will fail with an infinite recursion error. This is due purely because it
  # is impossible to determine if a value is a string without first evaluating
  # it and in order to construct the equivalent attribute set:
  #  
  #  { favorite = 
  #    { text = "My Blue color is very ${x.favorite.color}";
  #      color = 256; 
  #    }
  #  }
  # One must first evaluate the text. Because the last line contains an
  # accessor (`x.favorite.color`) which points to some data inside `favorite`
  # we get a infinite recursion error. However, if the data is note defined in
  # the same texts_ list then we can use normal string interpolation with no
  # issues:
  #
  #  merge_
  #   [ (x: { color.blue = 256; })
  #
  #     (conix: { favorite = texts_ [ 
  #        "My " 
  #        ({ color = conix.color.blue; text = "Blue"; })
  #        " color is very ${s conix.color.blue}"
  #     ];})
  #   ]
  # Will work.
  # 
  # 
  mergeTexts 
    # forall r. { text : String | r } -> Lazy String | { text : String | r }  -> { text : String | r }
    = a: b:
    if builtins.isString b 
    then a // (text_ ((a.text or "") + b))
    else (mergeModule a b) // (text_ ((a.text or "") + b.text)); 

  texts_ = 
    builtins.foldl' mergeTexts {};

  # These are helper functions to make common functions less invasive.
  # These may need to be thrown away later on.
  s = builtins.toString;

  t = text_;

  l = list: f:
    texts_ (builtins.map f list);

  conixApi = x: 
    { inherit s t l texts_ merge_;
      pkgs = pkgs;
    };

  eval = mkModule: 
    let
      toplevel = mergeModuleFunc mkModule conixApi;
    in
      lib.fix toplevel;

  test = merge_ 
    [ 
      (pure_ { c = 8; })
      (x: { t = x.texts_ [
        ''x.c = 
            ${s x.c} +''(t x.t.x)'' - ''(t x.t.x)'' | t.x = ''({ x = 4; text = "4"; })''

            =''(t (x.c + x.t.x))'' - ''(t x.t.x)''

            = ${s x.c} 
            qed.
        ''];
      })
      (x: { color.blue = 256; })
   
      (conix: { favorite = conix.texts_ [ 
         "My " 
         ({ color = conix.color.blue; text = "Blue"; })
         " color is very ${s conix.color.blue}"
      ];})
    ];

  r = eval test;
}
