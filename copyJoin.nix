pkgs:

rec
{ 
  docs.collect.docstr = ''
    Copy contents of paths to a single directory. If a path is a directory 
    its contents are copied and not the directory itself.

    For example, given:

    ```
    A
     |- a.txt

    B
     |- c.txt
    ```

    `dir "C" [ A B]` will produce:

    ```
    C
     |- a.txt
     |- b.txt
    ```

    NOTE: the later directories in the list could overwrite contents from
    other directories. If you wish to copy directories as is use. `dir`
    '';
  docs.collect.type = "Name -> [ Derivation | Path ] -> Derivation";
  collect = copyJoin false;

  docs.dir.docstr = ''
    Like `collect` but preserves toplevel directories when copying
  '';
  docs.dir.type = "Name -> [ (FilePath | Derivation) ] -> Derivation";
  dir = copyJoin true;

  docs.copyJoin.type = "Name -> [ Derivation ] -> Derivation";
  copyJoin = preserveTopLevelDirs: name: paths:
    pkgs.runCommand name { passAsFile = [ "paths" ]; inherit paths; }
      ''
      mkdir -p $out
      for i in $(cat $pathsPath); do
        if [[ -d $i ]]; then
          cp -r $i/${if preserveTopLevelDirs then "" else "*"} $out/${if preserveTopLevelDirs then "$(stripHash $i)" else ""}
        else
          cp $i $out/$(stripHash $i)
        fi
      done
      '';
};
