pkgs: {composeFmap, ...}: rw: content:

rec
{  
  docs.contentWriter.fmap.type = "(a -> b) -> RWF (ContentF a) -> RWF (ContentF b)";
  fmap = composeFmap rw.fmap content.fmap;

  docs.contentWriter.eval.type = "(AttrSet -> { data = AttrSet; text = String; }) ~ a => RWF (ContentF a) -> a";
  eval = match
    { "pure" = _: __: { data = {}; text = "";};
      "ask"  = f: x: f x x; # AttrSet -> AttrSet -> { data, text }
      "tell" = {_entry, _next}: x: 
        let 
          res = _next x;
        in
          { data = pkgs.lib.attrsets.recursiveUpdate res.data  _entry; 
            text = res.text;
          };
      "text" = text: _: { data = {}; inherit text; };
    };
}
