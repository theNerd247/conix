(import <nixpkgs> { overlays = import ../default.nix; }).conix.build.htmlFile "readme" 

(conix: conix.texts [] [
''# ''(conix.homePageLink)" - "(conix.version.text)''

''(conix.buildStatusBadgeMd)''


'' 
# Conix is a nix library for writing and building documents while making it
# easy to duplicate content and change the output format.
# 
# Conix is a template language EDSL for the nix programming language 
# 
# Conix aims to build off of languages like markdown, restructured text,
# and the like.
#
# Conix is an EDSL for writing content
# 
# Conix provides the full power of a programming language to markdown
#
# Conix makes it easy to mix languages for building documents: we can extend
# the syntax of markdown in arbitrary directions because we are wrapping the
# markdown in a functional programming language.
# 
# It aims to make it easy to re-use content while authoring documents.
''

# A taste of Conix

Compare the following markdown content to the same document written in conix.

__Markdown Sample__
```markdown
${builtins.readFile "${import ./sample.nix}/Volunteers.md"}
```

__Conix Sample__
```nix
${builtins.readFile ./sample.nix}
```

''
# Yup! You guessed it - the markdown syntax is simpler[^1]. And that's the problem.
# It's deceptively too simple. Here's a list of problems when dealing with
# traditional markdown-based content:
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

* [Pollen][1] - _"Pollen is a publishing system that helps authors make functional and beautiful digital books."_

[^1]: This readme file was generated using conix! And the sample source code
  you see there can be found at `./readme/sample.nix` and the markdown above it
  was produces by building the sample.nix file.

[1]: https://docs.racket-lang.org/pollen/
''])
