conix: with conix; { gettingStarted = _use (exprs.html "getting-started" [
  (exprs.meta [
    (_ask (exprs.css exprs.conixCss))
    (_ask (exprs.pagetitle "Conix Tutorials"))
  ])

''
# Getting Started With Conix

## Goals

  * Create a Markdown file using Conix
  * Extend the above conix code to produce an HTML file
  

''

{ gettingStartedText = [''## A Readme File In Conix

Below is some conix code for generating a readme file^[Download
[Getting Started Sample Code](''(_link refs.tutorials.gettingStartedNix)'')]
as HTML and Markdown files.

''(_use (exprs.tutorialSnippet "gettingStarted.nix" "gettingStartedNix" [

{ conixImport = [
''(import <nixpkgs> { overlays = import (builtins.fetchGit 
    ''(exprs.conix.git.text)''); 
})''];}{ conixRun = ''.conix.run''; }''(conix: with conix;


''{ readmeSample = ''
markdown "readme" (html "readme" '''

# My Readme

This is a readme file!

'''))

''; }]))

];}''

Here's the break down. 

The first bit:

''(exprs.code "nix" (_ask data.conixImport))''
is normal nix code. It fetches a commit of the library from the conix repo, imports
it, and then passes in a given function.
overlay

The next bit: `''(_ask data.conixRun)''` runs the conix content and returns
a derivation containing the rendered files (in this case an html and markdown
file).

From [The Conix Language Reference](''(_link refs.conixFunctionSyntax)''), the
function syntax:

>''(_ask data.conixFunctionSyntax)''

''

]);}
