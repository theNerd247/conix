conix: conix.texts [ "design" "core" ] [
''# Core

Conix's design is similar to the nixos module system. 

  1. Users construct an nested attribute set (called the content tree) such
  that leaf values can be constructed using other leaf values. 
  1. The resulting attribute set is then used to render the content in
    a specified output format (such as markdown, html, or a pdf).

The core data type for conix is `Module`. Here's a rough type description:


    ```
    Module a = { pages = AttrSet; val = a; };
    ```
If you're familiar with Haskell this is the `Writer` monad where `pages` refers
to the writer monoid and val is a contained value. 


`pages` is the partial attribute set that contains the user's content tree. We use
`recursiveUpdate` as our monoid product:

  ```
  mergePages :: AttrSet -> AttrSet -> AttrSet
  mergePages = self.lib.attrsets.recursiveUpdate;
  ```

'']
