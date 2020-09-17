let
  L = import ./label.nix;
  F = import ./fs.nix;
  M = import ./markup.nix;
  Fr = import ./free.nix;
in

# type ContentF = Freer (L + F + M)

# Re-export constructors to build the toplevel api
{ 
  # Label re-exports
  tell = L.tell;
  ask  = L.ask;

  # FS re-exports
  file = F.file;
  local = F.local;
  dir = F.dir;
  markdown = F.markdown;
  pandoc = F.pandoc;
  noFile = F.noFile;

  # Markup re-exports
  text = M.text;

  # convenience constructors
  docs.content.end.type = "ContentF ()";
  end = Fr.pure null;

  # Freer re-exports
  fmap = Fr.fmap;
  sequence = Fr.sequence;
}
