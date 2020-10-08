pkgs:

rec
{ 
  docs.collect.type = "Name -> [Derivation] -> Derivation";
  collect = copyJoin "";

  docs.dir.type = "Name -> [Derivation] -> Derivation";
  dir = name: copyJoin name name;

  docs.copyJoin.type = "FilePath -> Name -> [ Derivation ] -> Derivation";
  copyJoin = target: name: _paths:
    let
      paths = builtins.filter (x: x != {}) _paths;
    in
    pkgs.runCommand name { passAsFile = [ "paths" ]; inherit paths; }
      ''
      target=$out/${target}

      mkdir -p $target

      for i in $(cat $pathsPath); do
        if [[ -d $i ]]; then
          if [[ -n "$(ls -A $i)" ]]; then
            cp -u -r $i/* $target/
          else
            echo "skipping copying of empty dir $i"
          fi
        else
          cp -u $i $target/$(stripHash $i)
        fi
      done
      '';
}
