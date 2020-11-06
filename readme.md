# Conix 0.2.0

Conix is a Nix EDSL for technical writing. It brings the Nix
programming language alongside markdown and implements an
intuitive build system.

**Notice: This project is a work in progress. The API will be unstable
until the first major release.**


# Documentation

  * [Conix Home Page](https://theNerd247.github.io/conix)

## A Readme File In Conix

Below is some conix code for creating a readme file^[Download
[Getting Started Sample Code](./gettingStarted.nix)]
as both an HTML file and a Markdown file.

```nix

(import <nixpkgs> { overlays = builtins.fetchGit 
{ ref = "conixSnippets"; rev = "2e3bb44724ffe68236aa6898e931280f3d5b46ef"; url = "https://github.com/theNerd247/conix.git"; }; 
}).conix.run (conix: with conix;

markdown "readme" (html "readme" ''

# My Readme

This is a readme file!

''))


```

# Contributing

Any ideas or help are welcome! Please submit a PR or open an issue as you see
fit. I like to use the project board to organize my thoughts; check the todo
column for tasks to work on. I will try and convert these to issues when I can.

# Related Works

* [Pollen](https://docs.racket-lang.org/pollen/) - _"Pollen is a publishing
system that helps authors make functional and beautiful digital books."_

# Acknowledgements

Many thanks to:

  * [Gabriel Gonzalez](https://github.com/Gabriel439)
  * [Evan Relf](https://github.com/evanrelf)
  * [Paul Young](https://github.com/paulyoung)
