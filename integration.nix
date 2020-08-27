conix: { lib.docs.integration = with conix.lib; using [ (markdownFile "integration") (htmlFile "integration" "--metadata pagetitle=\"Integrating With Conix\"")] (
texts [''
# How To Integrate Your Reference Documentation With Conix

1. Write a program that consumes your language and produces a conix Page.
Here's a suggested pipeline:

  ```
  Parse Code 
  -> Extract doc strings and other reference material 
  -> Generate Nix file that defines a conix Page where the module contains Attribute sets formatted 
  as `{ type : String; docstr : String; todo = [ String ]; }`
  ```
1. Write your tutorials / other documentation using conix (see the
documentation on how to use conix)
1. Include generated conix page in your pages list when calling `buildPages :
${docs.buildPages.type}`
1. Now you're ready to safely reference different parts of your documentation.

Here's an example:

Let's say you have this in a C header file:

  ```c
  /* ''(label "sampleDocStr" "Adds 3 to the given integer.")'' */
  ''(label "outputType" "int")(label "funcName" "add3")''(''(label "inputType" "int")'' x); 
  ```

An example output of the above program would be a file called `docs.nix`:

  ```nix
''(label "sampleDocFile" ''
conix: { docs = 
  { ''(t docs.integration.funcName)'' =
    { type = "''(t docs.integration.outputType)''";
      docstr = "''(t docs.integration.sampleDocStr)''";
    };
  };
}
'')''
  ```

And in your toplevel build:

''(
  let
    file = conix.pkgs.writeFile "docs.nix" docs.integration.sampleDocFile;
    mainCode = ''
      (import <nixpkgs> {
        overlays = import (builtins.fetchGit
          ${conix.lib.indent 4 conix.lib.git.text}
        );
      }).conix.buildPages
      [ (import ./docs.nix)
        (c: { drvs = [ (markdownFile "docs" c.docs) ];)
      ]
      '';

    main = conix.pkgs.writeFile "default.nix" mainCode; 

    buildDir = dir "sampleDocs" [ file main ];
  in
    set "sampleBuild" (snippet "nix" mainCode (readConixResult buildDir))
)''


# How to Write Executable Examples In Your Documentation

# Why Use Conix To Write Your Documentation

''

]);}
