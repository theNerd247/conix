with (import <nixpkgs> { overlays = import ../conix.nix; }).conix; 

build.pdfFile "Volunteers" textsWith (pages: [ (t 
''# Volunteer Handbook

## Emergency Plan

Incase of an emergency please contact: 
${pages.contacts.row2.col0.text} at ${pages.contacts.row2.col1.text}

## Volunteer Contacts 

We still need ${builtins.toString (8 - pages.contacts.rows.length)}
volunteers. 

'')
(table [ "contacts" ]
    ["Name"   "Phone" ]
   (sortRows [["John"   "555-123-4563"]
    ["Jacob"  "555-321-9872"]
    ["Jingle" "555-231-7589"]
   ])
)
])
