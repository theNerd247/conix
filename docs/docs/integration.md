# How To Integrate Your Reference Documentation With Conix

1. Write a program that consumes your language and produces a conix Page.
   Here's a suggested pipeline:

   1. Parse Code 
   1. Extract doc strings and other reference material 
   1. Generate Nix file that defines a conix Page where the module contains
      attribute sets of type `{ docstr : String; type = String; todo = [ String ]; }` in its leaves.

1. Write your tutorials / other documentation using conix (see the
   documentation on how to use conix)

1. Include generated conix page in your pages list when calling `buildPages : [ Page ] -> Derivation`

1. Now you're ready to safely reference different parts of your documentation.

Here's an example:

Let's say you have this in a C header file:

  ```c
  /* Adds 3 to the given integer.*/
int add3(int x); 
  ```

An example output of the above program would be a file called `docs.nix`:

  ```nix
conix: { docs = {
  add3 =
    { type = "int";
      docstr = "Adds 3 to the given integer.";
    };
}; }
  ```

And in your toplevel build:

```nix
(import <nixpkgs> {
  overlays = import (builtins.fetchGit
    { 
      url = "https://github.com/theNerd247/conix.git";
      ref = "master";
      rev = "e4f956c716f9af6d0c830adbb433dbf081a7eec2";
    }
    
  );
}).conix.buildPages
[ (import ./docs.nix)
  (c: { drvs = [ (c.lib.markdownFile "docs" c.docs) ]; })
]


```



# How to Write Executable Examples In Your Documentation

# Why Use Conix To Write Your Documentation

