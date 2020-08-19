# Conix Documentation - 0.1.0

## Reference
<hr/>
Builds a page that expects the toplevel module to contain an attribute called `drv`.
Drv typically should be a derivation containing the toplevel render of the content


```haskell
build :: Page -> Derivation
```
<hr/>
Merges the pages into one and then calls `build`.


```haskell
buildPages :: [ Page ] -> Derivation
```
<hr/>
Copy the modules, derivations, and paths into a directory with the given name.


```haskell
dir :: Name -> [ Module | Derivation | Path ] -> Module
```
<hr/>


```haskell
emptyModule :: Module
```
<hr/>
This is the evaluator for a page and returns the final module.

```haskell
eval :: Page -> Module
```
<hr/>
Convenience functions for collecting multiple pages and evaluating
them all at once.


```haskell
evalPages :: [ Page ] -> Module
```
<hr/>
Fold an attribute set down while allowing for attribute sets to be a leaf value. 

The first function returns true if the given attribute set is a leaf value.
The second function maps leaf values to final values.
The third function returns a combined final value from the final values of the lower branches.

For example, to sum the leaf values in an attribute set where a leaf is either a nix value
or attribute set containing "stop" as an attribute is:

```nix
countLeaves = foldAttrsCond 
  # An attribute set is a leaf if it contains "stop" as an attribute.
  (s: s ? stop) 
  # return the value 1 for each leaf. We don't need the actual value to compute the result.
  (_: 1)        
  # countMap is a flat attribute set containing the previously counted branches.
  (countMap: builtins.foldl' (sum: count: sum + count) 0 (builtins.attrValues countMap));

# This should return 5.
nleaves = countLeaves { a = { b = "b"; c = "c"; }; d.e.f = "f"; g = { h = { stop = 2; }; i = 7; }; };
```


```haskell
foldAttrsCond :: (a -> Bool) -> (a -> b) -> (AttrSet b -> b) -> AttrSet a -> b
```
<hr/>
This is just like `foldAttrsCond` except the function to convert leaf
values into final values also takes in the path from the top of the
attribute set for that leaf value.


```haskell
foldAttrsIxCond :: ((AttrSet e ) -> Bool) -> (a -> Path -> b) -> (AttrSet b -> b) -> AttrSet a -> Path -> b
```
<hr/>
Maps elements to a module and merges the modules;


```haskell
foldMapModules :: (a -> Module) -> [a] -> Module
```
<hr/>
Maps elements to a page and then merges the pages

```haskell
foldMapPages :: (a -> Page) -> [a] -> Page
```
<hr/>
Merges a list of modules

```haskell
foldModules :: [Module] -> Module
```
<hr/>


```haskell
foldPages :: [ Page ] -> Page
```
<hr/>
Writes a html file to the nix store given some module who's `drv` builds to a markdown file.


```haskell
htmlFile :: Name -> Module -> Module
```
<hr/>
This is a convenience function for users to create new modules within texts
without needing to manually create modules


```haskell
label :: Path -> Text -> Module
```
<hr/>
Builds a markdown file derivation with the given name to the nix store.

_Todo_

* Maybe refactor the text out?
```haskell
markdownFile :: Name -> Module -> Module
```
<hr/>
Modules merge by recursiveUpdate but the toplevel text fields
are concatenated.


```haskell
mergeModules :: Module -> Module -> Module
```
<hr/>
A Page is the toplevel type used throughout conix. 


```haskell
mergePages :: Page -> Page -> Page
```
<hr/>
Construct markdown content for a documentation data structure 

_Todo_

* Right now this is not language agnostic...maybe it should be?
```haskell
mkDocModule :: { name : String; docstr : String; type : String }
```
<hr/>
Create a module using the given nix snippet code and
the evaluated result.

The text is markdown (see snippet for the template)

_Todo_

* This fails in an stack overflow / infinite recursion issue if:

  * the code is importing conix via a fetch git (using `./git.nix`)
  * and we're building the conix documentation.

  For example the `readme/sample.nix` works on its own, however if its
  text is passed in as the `code` argument inside of the readme derivation
  we get infinite recursion.

```haskell
nixSnippetWith :: Name -> String -> Module
```
<hr/>
Writes a file of the specified type to the nix store using pandoc.

_Todo_

* Remove hardcoded markdown input type
```haskell
pandoc :: Name -> Type -> { buildInputs : [ derivation ] } -> Module -> { drv : Derivation }
```
<hr/>
Writes a pdf file to the nix store given some module who's `drv` builds to a markdown file.


```haskell
pdfFile :: Name -> Module -> Module
```
<hr/>
This is like `label` but for nesting a module. We can't have just `label` and check whether the
input is a string or attribute set (yet? see todo for `toTextModule`) because doing so triggers
infinite recursion. Thus we need a separate function to achieve the same task.


```haskell
set :: Path -> Module -> Module
```
<hr/>
An alias for `builtins.toString`
This is a convenience function so users don't clutter up their content
with long bits of code for small things.


```haskell
str :: (IsString t) => String
```
<hr/>
This is an alias for `text`.
A convenience function for creating 
TODO: it might be a better user experience to rename this to `txt` instead.


```haskell
t :: (IsString t) => t -> Module
```
<hr/>
This is the most common function for constructing content for the user.
It allows them to write plain text and assignments alongside each other.
Here's an example:

```nix
conix: { report = conix.lib.texts [
  ''
  The final count for the muffin competition was:
  ''
  (conix.lib.md.list "muffinCount"
    [ "Blue Berry: ${t (builtins.length conix.muffins.blueBerry)}"
      "Whole Grain:  ${t (builtins.length conix.muffins.wholeGrain)}"
    ]
  )
]; }
```


```haskell
texts :: [ String | Module ] -> Module
```
<hr/>
Converts either text or a module to a module. This is used by the `texts`
function.  NOTE: Use of this can cause infinite recursion issues. See the
Infinite Recursion discussion.

_Todo_

* It might be worth investigating whether I could use a small typing system
      and if x has no type then assume it's a raw, stringable nix value

```haskell
toTextModule :: (String | Module)  -> Module
```
<hr/>
This is a quick fix function to merge the result of a builder with the 
module that produced it. The goal is to give the user less things to
worry about when creating modules.


```haskell
using :: (Module -> Module) -> Module -> Module
```
<hr/>
Build the given module as markdown and then as the given builder. Finally, save
both files in a directory. Both files and the directory will have the given name.

Typically this should be used with `htmlFile` or `pandocFile`.


```haskell
withMarkdownFile :: Name -> (Name -> Module -> Module) -> Module -> Module
```
## Discussion

### Modules

Modules are the core of conix. Their type is defined as:

```haskell
Module = { text : String; ... }
```

The rest of the attribute set defines the structure of the user's
content (including the derivations containing the rendered output).

For example the final module describing a single markdown file might
look like:

```nix
{ drv = <derivation>; 
  text = "Call me at: 555-123-456"; 
  phone = "555-123-456"; 
}
```

Here the user has the text for the markdown file; the derivation of the
built markdown file and some extra data containing the phone number.

Modules are meant to allow the user to describe the textual structure of
their content and the structure of the rendered in the same data structure.

The empty module contains nothing. The core functions defined in this file
treat the missing text value as an empty string to save memory.


### Pages

TODO

### Infinite Recursion

TODO


---
Built using <a href="https://github.com/theNerd247/conix.git">conix</a> version 0.1.0
