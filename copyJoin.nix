self: super: 
{ copyJoin = name: paths:
    super.runCommand name { passAsFile = [ "paths" ]; inherit paths; }
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
}
