(import <nixpkgs> { overlays = import ../default.nix; }).conix.build.htmlFile "readme" 

(conix: conix.texts [] [
''# ''(conix.homePageLink)" - "(conix.version.text)" - "(conix.buildStatusBadgeMd)''

**Notice: This project is a work in progress and the API will have major
updates pushed to the master branch until the first major release.**

Conix is a nix library for writing documents. It's primary goal is to make it
easy to re-use pieces your content without needing to write content.
Eventually I'd like to use it to replace markdown and _maybe_ make it user
friendly enough to replace word processors (for small things).

As an example this readme file was written using conix.

# A Taste of Conix

Compare the following markdown content to the same document written using
conix:

__Markdown Sample__
```markdown
${builtins.readFile "${import ./sample.nix}/Volunteers.md"}
```

__Conix Sample__
```nix
${builtins.readFile ./sample.nix}
```

A few points:

''#TODO: add the code samples corresponding to each item.
''
* The markdown sample was not hand written; the conix sample generated it.
* The table in the markdown sample has some of its contents duplicated across
the document. The conix sample simplifies this process.
* The number of volunteers is a computed value based on the number of rows in 
  the table:
* Conix provides an out-of-the-box build system for markdown (using
''(conix.text ["pandocLink"] "[Pandoc](https://pandoc.org)")'')
* 

''
# Yup! You guessed it - the markdown syntax is simpler[^1]. And that's the
# problem.  It's deceptively too simple. Here's a list of problems when dealing
# with traditional markdown-based content:
# 
#   * Markdown content often depends on the output format and markdown's
#     syntax will never cover all of the features of all the formats the can be
#     produced.

#   * Markdown content is often re-used (especially in reference material). Using
#     only markdown requires a lot of hand-copying which makes writing error
#     prone.

#   * Markdown content requires a hand-cranked build system. Users often scrape
#     together a bash script using various 3rd party programs like Pandoc. This
#     does not scale well.

#   * Markdown content does not have an output-independent syntax for internal
#     references across multiple files.
''

And that's only a few of them.

# Related Works

* ''(conix.text ["pollenLink"]
"[Pollen](https://docs.racket-lang.org/pollen/)")'' - _"Pollen is a publishing
system that helps authors make functional and beautiful digital books."_

[^1]: This readme file was generated using conix! And the sample source code
  you see there can be found at `./readme/sample.nix` and the markdown above it
  was produces by building the sample.nix file.

[1]: 
''])
