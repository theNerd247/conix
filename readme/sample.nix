with (import <nixpkgs> { overlays = import ../conix.nix; }).conix; 

build.pdfFile "Volunteers" (pages: texts [] [
''# Volunteer Handbook

## Emergency Plan

Incase of an emergency please contact: 
''(pages.textOf [ "contacts" "row2" "col0" ]) ''

## Volunteer Contacts 

We still need''(pureModule (builtins.toString (8 - pages.contacts.rows.length)))''
volunteers. 

''
(table [ "contacts" ]
    ["Name"   "Phone" ]
   (sortRows [["John"   "555-123-4563"]
    ["Jacob"  "555-321-9872"]
    ["Jingle" "555-231-7589"]
   ])
)
])
