conix: { design.core = conix.texts [
''# Core

Conix's design is similar to the nixos module system. Below
is the process conix uses to generate it output.

```
|------------------|     |-------------------|     |---------------------|
| Construct A Page | ==> | Builder evaluates | ==> | Derivation Produced |
|------------------|     |-------------------|     |---------------------|
```

1. The user uses the conix library to construct what's called a Page.
1. The user specified builder then evaluates that page
1. The final result is a derivation that contains the PDF file, static website,
  or whatever target formats a builder produces.

## Pages

A page is simply a function that takes a module as input and returns a module 
as output. The input ALWAYS refers to the final module to be produced. The 
output module is some portion of that final module. 

For example:

  ```nix
  page1 = (x: { page1 = { text = "My first page"; }; })
  page2 = (x: { page2 = { text = "My second page is before $${x.page1.text}"; }; })
  allPages = mergePages page1 page2
  ```

`page1` and `page2` are pages that return a single module each. The `x` is
the input to for a page and refers to the final module that is created when
`allPages` gets evaluated.

`allPages` combines the output of both pages and returns that. When evaluated
`allPages` will produce the value stored in `x` (the argument to each page):

  ```nix
  x = 
    { page1 = { text = "My first page"; }; 
      page2 = { text = "My second page"; }; 
    }
  ```

## Modules

The core data type for conix is a module. A module is a attribute set that
stores the content a user writes. Modules maybe nested attribute sets or not
depending on how complex the content the user is writing.

Some modules may contain a toplevel `text` attribute. These text attributes are
concatenated together when 2 or modules get merged. For example:

  ```nix
  s = { text = "a"; x = 4; }
  t = { text = "b"; y = 5; }
  u = { text = "c"; }

  foldModules [ s t u ]
   => { text = "abc"; x = 4; y = 5; }
  ```
Text attributes in nested attribute sets _are not_ propagated up the tree. So

  ```nix
  s = { text = "a"; x = 4; }
  t = { u = { text = "b"; }; }
  mergeModules s t 
    => { text = "a"; x = 4; u = { text = "b"; }; }
  ```

## Evaluation

Modules can be hand written by the user. However, recall one of the goals:

> ''(conix.textOf [ "goals" "list" "goal1" ])''
Long story short a good portion of conix is simply providing functions to make
this construction easier. This includes giving users access to the final 
content tree. This is done by having the user construct functions of this type:

  ```
  someContent # AttrSet -> AttrSet
  someContent = conix: conix.texts [ "content" "path"] [ ... ];
  ```
where `conix` is `{ pages = {...}; ...<conix library functions> }` and the
return value is a portion of the final content tree that the user is
constructing.

Evaluating these functions is done by the `runModule` function in `./run.nix`.
This function uses the fixed point function. With that said - be cautious about
how modules are constructed - infinite loops can occur and nix will fail to run
as a result.

## Builders

A builder is a function that receives the final content tree and creates a
derivation with the final format of the content. For example the `pandoc.nix`
file contains builders that use Pandoc behind the scenes to construct HTML or
PDF output.

## Project Directory Structure

Below are some of the main files for this project:

```
|- ./core.nix
|- ./eval.nix
|- ./meta.nix
|- builders/
  |- pandoc.nix
  |- markdown.nix
```

`./pages.nix`
  : lowlevel functions for manipulating and constructing modules are here.

`./run.nix`
  : this contains the toplevel `runModule` function and functions that require
    access to the final content tree

`./builders/`
  : directory containing various builders for each

`./meta.nix`
  : conix a module that contains the project's meta data.


'']
