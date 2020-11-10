conix: with conix; { languageRef = _use (exprs.html "language-reference" [

(exprs.meta [
  (exprs.css exprs.conixCss)
  (exprs.pagetitle "Conix Language Reference")
])

''# Conix Language Reference

Below are Nix expressions that are converted into core like data structures:

''{ nixToConixRef = exprs.table [ "Nix Expression" "Notes"] I.docs.liftNixValue.docstr ;}''

## Glossary

content
: Conix code is just normal Nix source code that is evaluated to produce the
stuff that goes into text files and documents as well a derivation containing
those documents. We need a term to differentiate between normal Nix code and
Nix code that is to be evaluated by Conix. That is what we call "content":
normal Nix code that is evaluated by Conix to produce the document contents
and the documents themselves.

`data`
: An attribute set containing all user defined variables. You can set a value
in data via the attribute set syntax.
: ''{ dataWithWarning = ''NOTICE: Do not use the `with` syntax with `data` (i.e: `with data;`). Under
the hood nix needs to evaluate just enough of data to get its toplevel attribute
keys. Because `data` is the result of a fixed-point `with data;` will result
in infinite recursion.''; }''

`refs`
: An attribute set containing all user defined content references.
: _NOTE: the warning for data also applies to `refs`. I.e: don't write `with refs;`.

content reference
: A content reference is the mechanism that Conix provides for creating things
like HTML hyper-links, or LaTeX's `hyperref`. A content reference is created 
using the attribute set syntax and can be consumed using `refs`. To

Like an anchor tag in html but more abstract. Creating a content reference
tells Conix to remember how to get to that particular piece of content from the
very top of the output derivation's file structure. If the target content
points to a file then a file path will be generated. If it points to content
within a file (say a paragraph) then the file path up to that file is created
and then the file path is extended with an anchor tag syntax. For example: `dir
"bar" (html "foo"  { someRef = "jazz"; })` creates a ref: `refs.somRefs = "./bar/foo.html#someRef"`

'']);}
