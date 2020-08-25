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
markdown. Conix is simply a library that makes it convenient to create the
content datastructure while writing markdown and then consume that data
structure without leaving the sentence the user is writing. 

Here's an example. Say I'm writing a sentence about how many buttermilk
biscuits and fried chicken [^I'm from the South...] that I need for a party:


  ```markdown
  ''(t conix.lib.docs.goals.sampleBiscuits.output)''

  ```

There is some logic going on here: 

  * 1 chicken feeds 3 people
  * 2 biscuits feeds 1 person

But if were to just write the above in a markdown file I'd have to compute
those numbers by hand...bleh! I'm a programmer...I'm lazy. I'd like the
computer to do the computing for me. Here's the same snippet written in conix:

''(sampleConixSnippet "sampleBiscuits" ''
texts [
''' 
# of guests: '''(label "guestCount" 9)'''

Fried Chickens: '''(t (conix.sample.guestCount / 3))'''

Buttermilk Biscuits: '''(t (conix.sample.guestCount * 2))
]
'')''

Now, using conix, we can tell the computer that the number of guests can be
referenced in other places of our content. Because the number is stored (not
its text) we can use it to compute how many chickens and biscuits we need for
the party.

## Goal 2

> ''(t (builtins.elemAt conix.lib.docs.goals.list 1))''

Markdown is amazing. However, building documents from multiple files is
difficult and often requires a bash script build system. Conix builds on the
solution to the first goal to provide a build system that's convenient.
The user describes the file structure of their output and conix takes
care of the rest. Here's an example:

```nix
${docs.readme.volunteerSample.code}
```

Here we've stated that the output should be a markdownFile. Conix
takes care of creating that markdown file with the final derivation's text.

We also have functions like `collect` and `dir`. Here are their reference 
documentation snippets:

''(prefixLines " >" (mkDocs {collect = docs.collect; dir = docs.dir; }).text)''


Conix is not restricted to just markdown support. Currently, though, conix uses
${conix.lib.docs.readme.pandocLink} to render the markdown content and html
files. However conix is easily extensible to support other build types.

'']; }
