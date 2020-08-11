# Goals

1. Allow users to describe relationships between different pieces of their
   content without breaking the natural flow of content. 
1. Provide intuitive build support for various output formats.

## Goal 1

> Allow users to describe relationships between different pieces of their
   content without breaking the natural flow of content.

Writing prose - especially technical documents - creates lot of implicit
relationships between content.

For example: 

> there are 2 goals stated at the top of this document.

The number stated above is computed by counting the number of elements in the
list above. This is a relationship between that statement and the list of
goals. 

Most of the time these relationships are very easy to determine in our heads
and just write them down - I mean, how hard is it to count to 2. However, problems arise when the relationship changes or the
content itself changes.

For example, if I were to add another goal to the above list then chances are I
would forget to go back and update the number in the above statement and some
reader would tell me of the typo. I would be embarrassed to have overlooked
such a small detail and yet easy number to come up with.

## Goal 2

> Provide intuitive build support for various output formats.
Markdown is amazing. And for small standalone documents - like readme files -
running a single command to build a file is easy. Heck, even hosted files on
GitHub automatically render as markdown. However, many documents are not simple
markdown files and often require messy build scripts.

Conix aspires to hide as much of the build process for documents as possible.

# Core

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

> Allow users to describe relationships between different pieces of their
   content without breaking the natural flow of content.Long story short a good portion of conix is simply providing functions to make
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

