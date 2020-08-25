conix: with conix.lib; { lib.docs.readme = using [(markdownFile "readme") (htmlFile "readme" "--metadata title=readme")] 
(texts [
''# ${homePageLink} - ${version.text} - ${buildBadgeLink}

${if conix.lib.version.major < 1
then ''
**Notice: This project is a work in progress and the API will have major
updates pushed to the master branch until the first major release.**
'' 
else ""
}

Conix is a nix library for writing documents. It's primary goal is to make it
easy to re-use pieces your content without needing to write content.
Eventually I'd like to use it to replace markdown and _maybe_ make it user
friendly enough to replace word processors (for small things).

As an example this readme file was written using conix.

# A Taste of Conix

To try out conix:

1. Copy the conix sample into a nix file.
1. `nix-build` that file
1. Open `./result` which is the conix generated markdown file.

''
(runNixSnippetDrvFile "volunteerSample" ''
(import <nixpkgs> { 
  overlays = import (builtins.fetchGit
    ${indent 4 conix.lib.git.text}
  );
}).conix.build (conix: { vol = with conix.lib; using [(markdownFile "Volunteers")] (texts [

'''# Volunteer Handbook

## Emergency Plan

Incase of an emergency please contact: '''
(t (conix.vol.contacts.at 2 0))" at "(t (conix.vol.contacts.at 2 1))'''.

## Volunteer Contacts 

_Volunteers still needed!: '''(t (8 - (builtins.length conix.vol.contacts.data)))'''_

'''

(set "contacts" (table
    ["Name" "Phone" ]
  [ ["John"   "555-123-4563"]
    ["Jacob"  "555-321-9872"]
    ["Jingle" "555-231-7589"]
  ]
))

]);})''
)''

* The markdown sample was not hand written; the conix sample generated it.
* The table in the markdown sample has some of its contents duplicated across
the document. The conix sample simplifies this process.
* The number of volunteers is a computed value based on the number of rows in 
  the table:
* Conix provides an out-of-the-box build system for markdown (using ''(label
  "pandocLink" "[Pandoc](https://pandoc.org)")''.

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

'']); }
