let
  T = import ./types.nix;
in

rec
{
  docs.label.tell.type = "AttrSet -> LabelF";
  tell = T.typed "tell";

  docs.label.ask.type = "Label";
  ask = T.typed "ask" null;
}
