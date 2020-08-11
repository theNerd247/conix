conix: conix.texts [ "design" "core" ] [
''# Core

Conix's design is similar to the nixos module system. 

  1. Users construct an nested attribute set (called the content tree) such
  that leaf values can be constructed using other leaf values. 
  1. The resulting attribute set is then used to render the content in
    a specified output format (such as markdown, html, or a pdf).
Here's a graphic to explain the process:

  ```
  |------------------------|     |-------------------|     |---------------------|
  | Construct Content Tree | ==> | Builder evaluates | ==> | Derivation Produced |
  |------------------------|     |-------------------|     |---------------------|
  ```

## Project Directory Structure

```
|- ./pages.nix
|- ./run.nix
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

## Modules

The core data type for conix is `Module`:


    ```
    Module a = { pages = AttrSet; val = a; };
    ```
If you're familiar with Haskell this is the `Writer` monad where `pages` refers
to the writer monoid and val is a contained value. 


`pages` is a partial attribute set that contains the user's content tree.
`recursiveUpdate` is used to merge pages of 2 different modules together
instead of the `//` operator. This prevents users from needing to do this
manually. _NOTE_: merging assumes that `val` contains text. This assumption is
made because Most of the time merging will be done with modules the user has 
authored. I suppose a good refactor would be to turn this into a high-order
function to give users the maximum flexibility.

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

'']
