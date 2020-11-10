conix: with conix; { gettingStarted = _use (exprs.html "getting-started" [
  (exprs.meta [
    (_ask (exprs.css exprs.conixCss))
    (_ask (exprs.pagetitle "Conix Tutorials"))
  ])

''
# Getting Started With Conix

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


''{ readmeSample = ''markdown "readme" (html "readme" '''

# My Readme

This is a readme file!

'''))

''; }]))

];}''

Here's the break down. 

The first bit:

''(exprs.code "nix" (_ask data.conixImport))''


is normal nix code. It fetches a commit of the library from the conix repo and
imports the library as an overlay.

The next bit: 
''(exprs.code "nix" (_ask data.conixRun))''

runs the conix content and returns a derivation containing the rendered files
(in this case an html and markdown file).

Finally, the conix content:

''(exprs.code "nix" (_ask data.readmeSample))''

The first line is a function that creates a markdown file called "readme". The
text in this readme file is produced by the argument content. In this 
example, the argument content to `markdown` is an expression that creates
an HTML file called "readme". The last argument to the readme file is a string
of markdown code. Here's the build pipeline:


''(exprs.digraph "conixEvaluation" ''

  Content -> "html 'readme'"

  "html 'readme'" -> HtmlDerivation
  "html 'readme'" -> MarkdownText
  "html 'readme'" -> "markdown 'readme'"

  "markdown 'readme'" -> MarkdownDerivation
  "markdown 'readme'" -> MarkdownText

'')''

From [The Conix Language Reference](''(_link refs.conixFunctionSyntax)''), the
function syntax:

>''(_ask data.conixFunctionSyntax)''

''

]);}
