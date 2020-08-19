# <a href="https://github.com/theNerd247/conix.git">conix</a> - 0.1.0 - ![CI](https://github.com/theNerd247/conix/workflows/CI/badge.svg?branch=master)

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
```nix
/nix/store/x982wsnl9q63xpa0r5fanagh5ln4ic62-Volunteers.md

```
output:

```
/nix/store/x982wsnl9q63xpa0r5fanagh5ln4ic62-Volunteers.md
```
* The markdown sample was not hand written; the conix sample generated it.
* The table in the markdown sample has some of its contents duplicated across
the document. The conix sample simplifies this process.
* The number of volunteers is a computed value based on the number of rows in 
  the table:
* Conix provides an out-of-the-box build system for markdown (using [Pandoc](https://pandoc.org)").

# Goals

# Goals


* Allow users to describe relationships between different pieces of their         content without breaking the natural flow of content.
* Provide intuitive build support for various output formats.

## Goal 1

> Allow users to describe relationships between different pieces of their         content without breaking the natural flow of content.

Writing prose - especially technical documents - creates lot of implicit
relationships between content.

For example: 

> there are 2 goals 
stated at the top of this document.

The number stated above is computed by counting the number of elements in the
list above. This is a relationship between that statement and the list of
goals. 

Most of the time these relationships are very easy to determine in our heads
and just write them down - I mean, how hard is it to count to 2. However, problems arise when the relationship
changes or the content itself changes.

For example, if I were to add another goal to the above list then chances are I
would forget to go back and update the number in the above statement and some
reader would tell me of the typo. I would be embarrassed to have overlooked
such a small detail and yet easy number to come up with.

## Goal 2

> Provide intuitive build support for various output formats.
Markdown is amazing. And for small standalone documents - like readme files -
running a single command to build a file is easy. Heck, even hosted files on
GitHub automatically render as markdown. However, many documents are not simple
markdown files and often require messy build scripts.

Conix aspires to hide as much of the build process for documents as possible.



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

