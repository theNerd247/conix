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

  _codeblock = language: contents: {
    _type = "codeblock";
    inherit language;
    inherit contents;
  };

  _include = filePath: contents: {
    _type = "include";
    inherit filePath;
    inherit contents;
  };

  _dir = name: contentsList: {
    _type = "dir";
    inherit name;
    inherit contentsList;
  };

  _file = name: contents: {
    _type = "file";
    inherit name;
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
    codeblock = x: x // { contents = f x.contents; };
    data = x: x // { contents = f x.contents; };
    dir = x: x // { contentsList = builtins.map f x.contentsList; };
    file = x: x // { contents = f x.contents; };
    include = x: x // { contents = f x.contents; };
    label = x: x // { contents = f x.contents; };
    list = x: x // { contentsList = builtins.map f x.contentsList; };
    merge = x: x // { contentsList = builtins.map f x.contentsList; };
    table = x: x // { headers = builtins.map f x.headers; rows = builtins.map (builtins.map f) x.rows; };
  };

  # (Module a -> a) -> Fix Module -> a
  cata = alg: x: alg (fmap (cata alg) x);
}
