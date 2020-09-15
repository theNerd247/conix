let
  T = import ./types.nix;
  L = import ./label.nix;
  F = import ./fs.nix;
  M = import ./markup.nix;
in

L // M // F //

(rec
{
  # ContentF a 
  end = T.typed "end" null;

  # ContentF = LabelF + MarkupF + FSF
  fmapMatch = f:
     L.fmapMatch f 
  // M.fmapMatch f 
  // F.fmapMatch f
  // { "end" = _: end; };

  fmap = T.matchWith fmapMatch;
})
