# Conix

Conix is a template language embedded in the nix programing language. It aims
to make it easy to re-use content while authoring documents, static websites;
really anything.

# A taste of Conix

Compare the following markdown content to the same document written in conix.

```
# Volunteer Handbook

## Emergency Plan

Incase of an emergency please contact: Jingle at 555-231-7589 

## Volunteer Contacts 

We still need 4 volunteers. 

Name   | Phone
---    | ---
John   | 555-123-4563
Jacob  | 555-321-9872
Jingle | 555-231-7589
```

```nix
let
  pkgs = (import <nixpkgs>) { overlays = [ (import ./co.nix) ]; };
in
  with pkgs.conix;

  builders.pdf.build (page "Volunteers" (pages -> [''
    # Volunteer Handbook

    ## Emergency Plan

    Incase of an emergency please contact: ${pages.Volunteers.contacts.jingle.Name} at ${pages.Volunteers.contacts.jingle.Phone}

    ## Volunteer Contacts 

    We still need ${8 - (builtins.length pages.Volunteers.contacts.rows)} volunteers. 

    ''
    (table "contacts" 
      { header = ["Name"   "Phone" ];
        rows  = [["John"   "555-123-4563"]
                 ["Jacob"  "555-321-9872"]
                 ["Jingle" "555-231-7589"]
                ];
      }
    )
  ]))
```

<!-- TODO: is it best to have a list of reasons why markdown fails? -->

The markdown content is much easier to read as plain text and is much shorter.
However, markdown is a poor choice of language when authoring any content that
is larger than the example provided above:

  * Content often depends on the output format and markdown's syntax will never
    cover all of the features of all the formats the can be produced.
  * Content is often re-used (especially in reference material); markdown
    provides no easy way to re-use content. 
  * Content authored in markdown requires a hand-cranked build system (for
    example using Pandoc and bash scripts).
  * Markdown content that is intended to be published in multiple formats often
    requires different syntax to be used for the same piece of content. For
    example, internal links within a document might be formatted using markdown
    links for html output but latex links for pdf output. 

Conix blends the convenience of a template language with the power of a
functional programming language. This allows authors to have the same features
as programmers with a frontend that is more convenient.

