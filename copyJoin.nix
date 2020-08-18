conix: { lib =
  { copyJoin = name: pathsOrModules:
      let
        paths = builtins.map (x: if x ? drv then x.drv else x) pathsOrModules;
      in
      conix.pkgs.runCommand name { passAsFile = [ "paths" ]; inherit paths; }
        ''
        mkdir -p $out
        for i in $(cat $pathsPath); do
          if [[ -d $i ]]; then
            cp -r $i/ $out/$(stripHash $i)
          else
            cp $i $out/$(stripHash $i)
          fi
        done
        '';
  };
}
