conix: with conix.lib; { lib.docs.goals = texts [
''# Goals


''(md.list "list" [
''
Allow users to use logic in writing prose without leaving
the sentence they are writing.
''
 
''
Provide intuitive build support for various output formats.
''
])''


## Goal 1

> ''(t (builtins.elemAt conix.lib.docs.goals.list 0))''

Good programmers separate data from how that data is rendered. The programmer
solves multiple problems with this paradigm:

  * Store duplicated data in a single place.
  * Generate new content with logic (for example a list of words is sorted
  before rendered).
  * Swap out the rendering system without changing the content's structure.

  ```
  Data --> Render --> Output
  ```
However, for writing prose the above solution becomes a problem. Here's what I
mean. The data an author is working with is the content that they are writing.
And if the author follows the above paradigm - for example by using JSON
and a templating language - then they must write their content separate from
how that document is to be rendered. Consider the following code that uses
JSON and a templating language[^I'm not using a real templating language; this
is just an example. Hopefully, it's clear enough]:

```json
chapters: [
  { sections = 
    [ 
      { contents: "..." }
      { contents: "..." }
      { contents: "..." }
      { contents: "..." }
    ]
    references = 
    [ ...
    ]
    notes = 
    [ ...
    ]
  }
]
```

```
Chapter {{chapters.index}

{{for section in chapter.sections}}

Section {{section.index}}

{{section.contents}}

{{endfor}}
```

This is a mess! If I'm writing a book I'd prefer to not have to write JSON.
It's not distributable across files, it's difficult to tell which section or
chapter I'm working on - I'd prefer to have a file per section and a directory
per chapter. Finally, what if the content that I write needs to depend on the
templating language? I've really broken the data/render separation above.
Templating languages do not solve the last problem above.

The family of Markdown and LaTex languages have user convenient interfaces for
rendering content however none of them provide the power of a programming
language[^Well maybe LaTeX does...but's not user friendly and has a steep
learning curve.]. They do not solve the first problems above.

There's no way around it. When we write prose we want to have the power that
programming gives us. Templating languages only solve half the problem, and
markdown only solves the other half (switching out the rendering system). And
neither allows us to use logic to create content.

Conix fixes all of these problems. Simply put conix uses the Nix programming
language as a host language for creating markdown and then processing that
markdown.

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
