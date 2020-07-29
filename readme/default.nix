with (import <nixpkgs> { overlays = import ../conix.nix; }).conix; 

build.htmlFile "readme" (conix: text [] ''
# Conix

Conix is a template language embedded in the nix programing language. It aims
to make it easy to re-use content while authoring documents, static websites;
really anything.

# A taste of Conix

Compare the following markdown content to the same document written in conix.

#### Markdown Sample
```markdown
${builtins.readFile "${import ./sample.nix}/Volunteers.md"}
```

#### Conix Sample 
```nix
${builtins.readFile ./sample.nix}
```

Yup! You guessed it - the markdown syntax is simpler[^1]. And that's the problem.
It's deceptively too simple. Here's a list of problems when dealing with
traditional markdown-based content:

  * Markdown content often depends on the output format and markdown's
    syntax will never cover all of the features of all the formats the can be
    produced.
  * Markdown content is often re-used (especially in reference material). Using
    only markdown requires a lot of hand-copying which makes writing error
    prone.
  * Markdown content requires a hand-cranked build system. Users often scrape
    together a bash script using various 3rd party programs like pandoc. This
    does not scale well.
  * Markdown content does not have an output-indpendent syntax for internal
    references across multiple files.

And that's only a few of them.

Conix blends the convenience of a template language with the power of a
functional programming language. This allows authors to have the same features
as programmers with a frontend that is more convenient.

[The Pollen programming language][1] addresses these problems as well. I adopt
their philosophy when it comes to writing: authoring content is like
programming.

# Related Works

* [Pollen][1] a turing complete typesetting language written in Racket.

[^1]: This readme file was generated using conix! And the sample source code
  you see there can be found at `./readme/sample.nix` and the markdown above it
  was produces by building the sample.nix file.

[1]: https://docs.racket-lang.org/pollen/
'')
