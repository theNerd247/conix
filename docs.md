# Conix Documentation - 0.1.0

## Reference

Builds a page that expects the toplevel module to contain an attribute called `drv`.
Drv typically should be a derivation containing the toplevel render of the content


```haskell
build :: Page -> Derivation
```


Copy the modules, derivations, and paths into a directory with the given name.


```haskell
dir :: Name -> [ Module | Derivation | Path ] -> Module
```


This is the evaluator for a page and returns the final module.

```haskell
eval :: Page -> Module
```


Convenience functions for collecting multiple pages and evaluating
them all at once. You might be looking for buildPages.


```haskell
evalPages :: [ Page ] -> Module
```


Writes a html file to the nix store given some module who's `drv` builds to a markdown file.


```haskell
htmlFile :: Name -> Module -> Module
```


This is a convenience function for users to create new modules within texts
without needing to manually create modules


```haskell
label :: Path -> Module -> Module
```


Builds a markdown file derivation with the given name to the nix store.


```haskell
markdownFile :: Name -> Module -> Module
```


Modules merge by recursiveUpdate but the toplevel text fields
are concatenated.


```haskell
mergeModules :: Module -> Module -> Module
```


A Page is the toplevel type used throughout conix. 


```haskell
mergePages :: Page -> Page -> Page
```


Writes a file of the specified type to the nix store using pandoc.


```haskell
pandoc :: Name -> Type -> { buildInputs : [ derivation ] } -> Module -> { drv : Derivation }
```


Writes a pdf file to the nix store given some module who's `drv` builds to a markdown file.


```haskell
pdfFile :: Name -> Module -> Module
```


An alias for `builtins.toString`
This is a convenience function so users don't clutter up their content
with long bits of code for small things.


```haskell
str :: (IsString t) => String
```


This is an alias for `text`.
A convenience function for creating 
TODO: it might be a better user experience to rename this to `txt` instead.


```haskell
t :: (IsString t) => t -> Module
```


This is the most common function for constructing content for the user.
It allows them to write plain text and assignments alongside each other.
Here's an example:

```nix
conix: { report = conix.lib.texts [
  ''
  The final count for the muffin competition was:
  ''
  (conix.lib.md.list "muffinCount"
    [ "Blue Berry: ${t (builtins.length conix.muffins.blueBerry)}
      "Whole Grain:  ${t (builtins.length conix.muffins.wholeGrain)}
    ]
  )
]; }
```


```haskell
texts :: [ String | Module ] -> Module
```


This is the core function that makes conix work.  It merges the current
attribute set and preserves the concatenates the toplevel text values. If
`b` is:

 * a string then the `a` has its `text` value concatenated with `b`
 * an attribute set then the resulting attribute set has its `text` field
 set to `a.text + b.text`.

**NOTE:** if `b` is a string then IT MUST NOT CONTAIN INTERPOLATIONS THAT
REFER TO RECURSIVE ATTRIBUTE VALUES THIS WILL CAUSE INFINITE RECURSION
ERRORS! For example:

  (conix: { favorite = texts [ 
     "My " 
     ({ color = 256; text = "Blue"; })
     " color is very ${str conix.favorite.color}"
  ];})

will fail with an infinite recursion error. This is due purely because it
is impossible to determine if a value is a string without first evaluating
it and in order to construct the equivalent attribute set:
 
 { favorite = 
   { text = "My Blue color is very ${x.favorite.color}";
     color = 256; 
   }
 }
One must first evaluate the text. Because the last line contains an
accessor (`x.favorite.color`) which points to some data inside `favorite`
we get a infinite recursion error. However, if the data is note defined in
the same texts list then we can use normal string interpolation with no
issues:

 mergePages
  [ (x: { color.blue = 256; })

    (conix: { favorite = texts [ 
       "My " 
       ({ color = conix.color.blue; text = "Blue"; })
       " color is very ${str conix.color.blue}"
    ];})
  ]
Will work.


```haskell
toTextModule :: (String | Module)  -> Module
```


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

---
Built using <a href="https://github.com/theNerd247/conix.git">conix</a> version 0.1.0
