rec
{
  _pure = data: {
    _type = "pure";
    inherit data;
  };

  _merge = contentsList:
  { _type = "merge"; 
    inherit contentsList; 
  };

  _modifyText = modifyText: contents:
  { _type = "modifyText";
    inherit contents;
  };

  _data = data: contents: {
    _type = "data";
    inherit contents;
    inherit data;
  };

  _label = path: contents: {
    _type = "label";
    inherit path;
    inherit contents;
  };

  _table = headers: rows: {
    _type = "table";
    inherit headers;
    inherit rows;
  };

  _list = contentsList: {
    _type = "list";
    inherit contentsList;
  };

  _include = drv: contents: {
    _type = "include";
    inherit drv;
    inherit contents;
  };

  _dir = path: contents: {
    _type = "dir";
    inherit path;
    inherit contents;
  };

  # Pattern matching on types defined in this file.
  matchOn 
    # { (merge | data | ... | file) : (Module -> a) } -> a
    = fs: x: 
    let
      invalidType = throw "Invalid type. Must be one defined in this file";
    in
      (fs.${x._type or invalidType} or invalidType) x;

  # TODO: verify this implementation does create infinite recursions.
  fmap = f: matchOn { 
    pure = x: x;
    data = x: x // { contents = f x.contents; };
    dir = x: x // { contents = f x.contents; };
    include = x: x // { contents = f x.contents; };
    label = x: x // { contents = f x.contents; };
    list = x: x // { contentsList = builtins.map f x.contentsList; };
    merge = x: x // { contentsList = builtins.map f x.contentsList; };
    modifyText = x: x // { contents = f x.contents; };
    table = x: x // { headers = builtins.map f x.headers; rows = builtins.map (builtins.map f) x.rows; };
  };

  # (Module a -> a) -> Fix Module -> a
  cata = alg: x: alg (fmap (cata alg) x);
}
