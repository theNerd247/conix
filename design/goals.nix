conix: with conix.lib; { lib.docs.goals = texts [
''# Goals


''(md.list "list" [
''
Tighten the relationship between content and how it's rendered.
''
 
''
Provide intuitive build support for various output formats.
''
])''


## Goal 1

> ''(t (builtins.elemAt conix.lib.docs.goals.list 0))''

Good programmers separate data from how that data is rendered. Using this paradigmn 
provides the programmer a solution to the following problems:

  * Store duplicated data in a single place.
  * Generate new content with logic (for example a list of words is sorted
  before rendered).
  * Swap out the rendering system without changing the content's structure.

  ```
  Data --> Render --> Output
  ```
However, for someone writing prose the above solution becomes a problem. That
is, the data an author is working with is also content that they are writing.
The 

And,
primarily, this is done as an attempt to keep duplicated data to a minimum. If
content is to be re-used it's stuffed into a data structure and then called
upon in multiple places in the rendering system. 

However, writing documents - particularly documentation - is not the place for
the separation of data and rendering.  What a person writes and how their
writing is displayed often go hand in hand.  For example, a newspaper or
resume. These mediums often provide limited realistate in which one's penwork
must be restricted to the 2 dimensions paper. I recognize that the didital 
brothers of these works may not have as much a restriction, but they do exist
nonetheless. They are not free, however, from the duplication problem or even
some of the advantages of keeping the content in well structured data.

Simply put:

  * There is a need to manipulate content as a data structure. This includes
    embedding logical statements into content that one writes.
  * Seperating content and how it's rendered is not possible for authors. Maybe for programmers,
    but not the daily writer.
  * 

## Goal 2

> ''(t (builtins.elemAt conix.lib.docs.goals.list 1))''

Markdown is amazing. And for small standalone documents - like readme files -
running a single command to build a file is easy. Heck, even hosted files on
GitHub automatically render as markdown. However, many documents are not simple
markdown files and often require messy build scripts.

Conix aspires to hide as much of the build process for documents as possible.

Part of the motiviation for this is to have the build process as integrated
with the content generation. This includes generating the 

'']; }
