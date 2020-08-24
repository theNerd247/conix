conix: { lib = rec
  { 
    docs.snippet.docstr = ''
      Create a module whos text is a code snippet with some evaluated output.
      If no output is provided then it's codeblock is omitted.
    '';
    docs.snippet.todo = [
      "Add an language for the output codeblock as a parameter"
    ];
    docs.snippet.type = "LanguageString -> CodeString -> OutputString -> Module";
    snippet 
      = language: code: output:
      let
        text = ''
          ```${language}
          ${code}

          ```
          ${if output == "" || output == null 
            then "" 
            else
            ''

            ===>

            ```
            ${output}
            ```
            ''
          }
          '';
      in
        { inherit text;
          inherit code;
          inherit language;
          inherit output;
        };

    docs.printNixVal.docstr = ''
      Pretty print a pure nix-value. 

      NOTE: do not call this function on a derivation as it will segfault.
      '';
    docs.printNixVal.type = "a -> String";
    printNixVal = e:
      if builtins.isAttrs e then printAttrs e
      else if builtins.isList e then printList e
      else if builtins.isNull e then "null"
      else if builtins.isFunction e then "<lambda>"
      else builtins.toString e;

    printAttrs = e:
      let
        printElem = name: value:
          "${name} = ${ printNixVal value };";

        printElems = 
          builtins.concatStringsSep " "
            (conix.pkgs.lib.attrsets.mapAttrsToList printElem e);
      in
        "{ ${printElems} }";

    printList = e:
      let
        printElems = builtins.concatStringsSep " "
          (builtins.map printNixVal e);
      in
        "[ ${printElems} ]";

    docs.runSnippet.docstr = ''
      Create a module using the given code snippet and a function that accepts
      the a nix store filepath containing the code.  `mkCode` handles executing
      the code file and producing the output expected by `snippet` 
    '';

    docs.runSnippet.type = "Name -> String -> String -> (FilePath -> String) -> Module";
    runSnippet = name: language: code: mkOutput:
      let
        codeFile = conix.pkgs.writeText "${name}.${language}" code;
      in
        conix.lib.set name (snippet language code (mkOutput codeFile));

    docs.runNixSnippetDrvFile.docstr = ''
      Run `runSnippet` for nix code that evaluates to a derivation that points
      to a single file. The output of the snippet is the contents of the file
      resulting from the derivation.
      '';
    docs.runNixSnippetDrvFile.type = "Name -> String -> Module";
    runNixSnippetDrvFile = name: code: 
      runSnippet name "nix" code (nixFilePath: "${builtins.readFile (import nixFilePath)}");

    docs.sampleConixSnippet.docstr = ''
      Creates a nix snippet using the given conix code. The content
      is put under a single attribute called "sample" and creates 
      markdown as its output.

      The expected code should evaluate to a module.

      Only the code the user writes will appear in the code block. Read the implementation
      for this function to see what will actually get evaluated.

      Use this if you're writing sample conix code and would like to verify that 
      you code works.
      '';
    docs.sampleConixSnippet.type = "Name -> String -> Module";
    sampleConixSnippet = name: code:
      let
        sampleCodeFile = conix.pkgs.writeText "${name}.nix"
          ''
          (import <nixpkgs> { 
            overlays = import (builtins.fetchGit
              ${conix.lib.indent 4 conix.lib.git.text}
            );
          }).conix.buildPages
            [ (conix: { drv = with conix.lib; markdownFile "${name}" conix.sample; })
              (conix: { sample = with conix.lib;
                ${code}
              ;})
            ]
          '';
      in
        conix.lib.set name (snippet "nix" code "${builtins.readFile (import sampleCodeFile)}");
  };
}
