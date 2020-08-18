conix: { lib =
  { 
    docs.dir.docstr = ''
      Copy the modules, derivations, and paths into a directory with the given name.
      '';
    docs.dir.type = "Name -> [ Module | Derivation | Path ] -> { drv : derivation }";
    dir = name: pathsOrModules:
      let
        paths = builtins.map (x: if x ? drv then x.drv else x) pathsOrModules;

        drv = conix.pkgs.runCommand name { passAsFile = [ "paths" ]; inherit paths; }
        ''
        mkdir -p $out
        for i in $(cat $pathsPath); do
          if [[ -d $i ]]; then
            cp -r $i/* $out/
          else
            cp $i $out/$(stripHash $i)
          fi
        done
        '';
      in
        { inherit drv; };
  };
}
