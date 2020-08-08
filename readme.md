# <a href="https://github.com/theNerd247/conix.git">conix</a> - 0.0.3 - ![CI](https://github.com/theNerd247/conix/workflows/CI/badge.svg?branch=master)
**Notice: This project is a work in progress and the API will have major
updates pushed to the master branch until the first major release.**

Conix is a nix library for writing documents. It's primary goal is to make it
easy to re-use pieces your content without needing to write content.
Eventually I'd like to use it to replace markdown and _maybe_ make it user
friendly enough to replace word processors (for small things).

As an example this readme file was written using conix.

# A Taste of Conix

To try out conix:

1. Copy the conix sample into `conix-sample.nix` file.
1. `nix-build ./conix-sample.nix`
1. Open the `result/Volunteers.md` file. 

__Markdown Sample__
```markdown
# Volunteer Handbook

## Emergency Plan

Incase of an emergency please contact: Jingle at 555-231-7589

## Volunteer Contacts 

_Volunteers still needed!: 5_

Name | Phone
--- | ---
John | 555-123-4563
Jacob | 555-321-9872
Jingle | 555-231-7589
```

__Conix Sample__
```nix
(import <nixpkgs> { 
  overlays = import (builtins.fetchGit
    { url = "https://github.com/theNerd247/conix.git";
    });
}).conix.build.markdownFile "Volunteers" 

(conix: conix.texts [] [
''# Volunteer Handbook

## Emergency Plan

Incase of an emergency please contact: '' (conix.textOf [ "contacts" "row2" "col0" ])" at "
(conix.textOf ["contacts" "row2" "col1"]) ''


## Volunteer Contacts 

_Volunteers still needed!: ''
(conix.mapVal (l: builtins.toString (8 - l)) (conix.at [ "contacts" "rows" "length"]))
''_

'' 
(conix.table [ "contacts" ]
  ["Name" "Phone" ]
  [ ["John"   "555-123-4563"]
    ["Jacob"  "555-321-9872"]
    ["Jingle" "555-231-7589"]
  ]
)
])

```

* The markdown sample was not hand written; the conix sample generated it.
* The table in the markdown sample has some of its contents duplicated across
the document. The conix sample simplifies this process.
* The number of volunteers is a computed value based on the number of rows in 
  the table:
* Conix provides an out-of-the-box build system for markdown (using
[Pandoc](https://pandoc.org)).

# Goals

1. Allow users to describe relationships between different pieces of their
   content. 
1. Provide intuitive build support for various output formats.

# Contributing

Any ideas or help are welcome! Please submit a PR or open an issue as you see
fit. I like to use the project board to organize my thoughts; check the todo
column for tasks to work on. I will try and convert these to issues when I can.
Please read the `./design.md` document for the design of conix.

# Related Works

* [Pollen](https://docs.racket-lang.org/pollen/) - _"Pollen is a publishing
system that helps authors make functional and beautiful digital books."_

# Acknowledgements

Many thanks to:

  * [Gabriel Gonzalez]() for his mentorship and guidance. 
  * [Evan Relf]() for his insightful feedback.

