

---
css: ./latex.css
pagetitle: Conix 0.2.0
---

# Conix 0.2.0

Conix is a Nix EDSL for technical writing. It brings the Nix
programming language alongside markdown and implements an
intuitive build system.

**Notice: This project is a work in progress. The API will be unstable
until the first major release.**


# Documentation

  * [Conix Home Page](https://theNerd247.github.io/conix)

## A Readme File In Conix

Below is some conix code for generating a readme file^[Download
[Getting Started Sample Code](./gettingStarted.nix)]
as HTML and Markdown files.

```nix
(import <nixpkgs> { overlays = import (builtins.fetchGit 
{ ref = "conixSnippets"; rev = "fafe5b22a6a7c3ab71b58e3fbf9922eb2666cd78"; url = "https://github.com/theNerd247/conix.git"; }); 
}).conix.run(conix: with conix;


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
