conix: with conix.lib; { lib.docs.readme = texts [
''# ${homePageLink} - ${version.text} - ${buildStatusBadgeMd}

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
1. Open the `result/Volunteers.md` file. ''#TODO: replace with generated html file.
''

''
# (conix.lib.nixSnippet "volunteersSnippet" ''
#   with (import <nixpkgs> { 
#     overlays = import (builtins.fetchGit
#       ${conix.lib.indent 4 conix.lib.git.text}
#     );
#   }).conix.build.markdown { name = "Volunteers"; text = conix: with conix.lib; texts [
# 
# '''# Volunteer Handbook
# 
# ## Emergency Plan
# 
# Incase of an emergency please contact: '''
# (t (conix.contacts.at 2 0))" at "(t (conix.contacts.at 2 1))'''.
# 
# ## Volunteer Contacts 
# 
# _Volunteers still needed!: '''(t (builtins.length conix.contacts.data))'''_
# 
# ( label "contacts" (table
#     ["Name" "Phone" ]
#   [ ["John"   "555-123-4563"]
#     ["Jacob"  "555-321-9872"]
#     ["Jingle" "555-231-7589"]
#   ];
# ))
# ]}
# ''
# )

''
* The markdown sample was not hand written; the conix sample generated it.
* The table in the markdown sample has some of its contents duplicated across
the document. The conix sample simplifies this process.
* The number of volunteers is a computed value based on the number of rows in 
  the table:
* Conix provides an out-of-the-box build system for markdown (using [Pandoc](https://pandoc.org)").

# Goals

${conix.lib.docs.goals.text}

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

  * [Gabriel Gonzalez]() for his mentorship and guidance. 
  * [Evan Relf]() for his insightful feedback.

'']; }
