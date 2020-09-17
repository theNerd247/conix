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

  # convenience functions
  docs.content.using.type = "(AttrSet -> [ContentF a]) -> ContentF ()";
  using = Fr.bind ask (x: Fr.sequence_ (mkContents x));

  docs.content.doc.type = "FileName -> RenderType -> (AttrSet -> [ContentF a]) -> ContentF ()";
  doc = _fileName: _renderType: mkContents:
    Fr.sequence_
      [ (FS.file { inherit _fileName _renderType; })
        (using mkContents)
      ];
}
