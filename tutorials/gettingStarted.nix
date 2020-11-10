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

Below is some conix code for creating a readme file^[Download
[Getting Started Sample Code](''(_link refs.tutorials.gettingStartedNix)'')]
as both an HTML file and a Markdown file.

''(_use (exprs.tutorialSnippet "gettingStarted.nix" "gettingStartedNix" [''

(import <nixpkgs> { overlays = import (builtins.fetchGit 
    ''(exprs.conix.git.text)'') {}; 
}).''{ conixRun = ''conix.run (conix: with conix;''; }''


''{ readmeSample = ''
markdown "readme" (html "readme" '''

# My Readme

This is a readme file!

'''))

''; }]))

];}''

Here's the break down. 

The first bit is normal nix code. It brings in the conix library as an
overlay.

The next bit: `''(_ask data.conixRun)''` runs the conix evaluator on the given
conix content. From [The Conix Language Reference](''(_link refs.conixFunctionSyntax)''), 
the function syntax:

>''(_ask data.conixFunctionSyntax)''

''

]);}
