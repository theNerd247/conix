# <a href="https://theNerd247.github.io/conix">conix</a> 

<div class="center">
![Travis Build Status](https://travis-ci.com/theNerd247/conix.svg?branch=master) - 0.1.0 - [GitHub Repo](https://github.com/theNerd247/conix.git)
</div>

**Notice: This project is a work in progress and the API will have major
updates pushed to the master branch until the first major release.**


Conix is a meta-language for extending markup languages and replacing their
build systems with convenience.

It brings the full power of the Nix programming language to Markdown, HTML,
LaTeX, or whatever language you fancy. It also brings convenience to the
build systems for creating markdown content.

# Resources

  * [Website](https://theNerd247.github.io/conix)
  * [Reference Documentation](https://theNerd247.github.io/conix/docs/docs.html)
  * [Goals](https://theNerd247.github.io/conix/docs/goals.html)
  * [Integrating With Doc Generators](https://theNerd247.github.io/conix/docs/integration.html)

# A Taste of Conix

To try out conix:

1. Copy the conix sample into a nix file.
1. `nix-build` that file
1. Open `./result` which is the conix generated markdown file.

```nix
(import <nixpkgs> { 
  overlays = import (builtins.fetchGit
    { 
      url = "https://github.com/theNerd247/conix.git";
      ref = "master";
      rev = "8433338d08704b39ce568c70b8a71b81c756bb93";
    }
    
  );
}).conix.build (conix: { vol = with conix.lib; using [(markdownFile "Volunteers")] (texts [

''# Volunteer Handbook

## Emergency Plan

Incase of an emergency please contact: ''
(t (conix.vol.contacts.at 2 0))" at "(t (conix.vol.contacts.at 2 1))''.

## Volunteer Contacts 

_Volunteers still needed!: ''(t (8 - (builtins.length conix.vol.contacts.data)))''_

''

(set "contacts" (table
    ["Name" "Phone" ]
  [ ["John"   "555-123-4563"]
    ["Jacob"  "555-321-9872"]
    ["Jingle" "555-231-7589"]
  ]
))

]);})

```
```

# Volunteer Handbook

## Emergency Plan

Incase of an emergency please contact: Jingle at 555-231-7589.

## Volunteer Contacts 

_Volunteers still needed!: 5_

Name | Phone
--- | ---
John | 555-123-4563
Jacob | 555-321-9872
Jingle | 555-231-7589
```


* The markdown sample was written by hand; conix generated it - read the [source
  code](https://github.com/theNerd247/conix/blob/master/readme/default.nix) for
  this file.
* The table in the markdown sample has some of its contents duplicated across
  the document. The conix makes it super easy to grab pieces of content across
  your document.
* The number of volunteers is a computed value based on the number of rows in 
  the table.
* Conix provides an out-of-the-box build system for markdown (using [Pandoc](https://pandoc.org). Long gone are the days
  of bash scripts and fancy ad hoc programs for static website generators. With
  conix you simply state what the output should look like and it takes care of
  the rest!

For more benefits of the language I highly encourage that you browse the source
code of this repository - the documentation for conix uses conix!

# Contributing

Any ideas or help are welcome! Please submit a PR or open an issue as you see
fit. I like to use the project board to organize my thoughts; check the todo
column for tasks to work on. I will try and convert these to issues when I can.
Please read the [./design.md](./design.md) document for the design of conix.

# Related Works

* [Pollen](https://docs.racket-lang.org/pollen/) - _"Pollen is a publishing
system that helps authors make functional and beautiful digital books."_

# Acknowledgements

Many thanks to:

  * [Gabriel Gonzalez](https://github.com/Gabriel439) for his mentorship and guidance. 
  * [Evan Relf](https://github.com/evanrelf) for his insightful feedback.
  * [Paul Young](https://github.com/paulyoung) for great feedback and ideas.

