conix: with conix; [''
# How To Write Documents in Conix

## A Basic File

1. Create a new file (the name is unimportant. for now we'll use "sample.nix")
  and add the following contents:

```nix
''{importStmnt = "with (import <nixpkgs> { overlays = fetchgit ...; }).conix;";}''

build (pdfPandocFile "jsTutorial" '''

# Page Title

## Section 1

## Section 2

## Section 3
```

''')

1. Run `nix-build ./sample.nix` and you should have a newpdf file called
"jsTutorial.pdf" in ./result.

## Re-Using Content

```nix
''(p: p.importStmnt)''

build (pdfPandocFile "jsTutorial" '''

# Page Title

## Section 1

## Section 2

## Section 3

```

## Multiple Files
