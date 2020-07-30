self: super:

{ conix = (super.conix or {}) //
  rec
  { linkTo 
      # For now we're going to assume that the first path entry is the
      # rendered file that will be pointed to. Anything beyond this will be
      # ignored. Note this doesn't make any guarentees that the link will not
      # be broken. Eventually this should be tied closely with the html builder
      # so that only non-broken links are generated.
      # 
      # Path -> Module Text
      = text: path: 
        if path == [] 
          then throw "linkTo was passed an empty path!" 
        else
          super.conix.pureModule "[${text}](/${builtins.head path}.html)";
  };
}
