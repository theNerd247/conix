(import <nixpkgs> { overlays = import ../conix.nix; }).conix.build.pdfFile "Volunteers" 

(conix: conix.texts [] [
''# Volunteer Handbook

## Emergency Plan

Incase of an emergency please contact: '' (conix.textOf [ "contacts" "row2" "col0" ])" at "
(conix.textOf ["contacts" "row2" "col1"]) ''


## Volunteer Contacts 

We still need''(conix.pureModule (builtins.toString (8 - conix.pages.contacts.rows.length)))''
volunteers. 

''
(conix.table [ "contacts" ]
    ["Name"   "Phone" ]
   (conix.sortRows [["John"   "555-123-4563"]
    ["Jacob"  "555-321-9872"]
    ["Jingle" "555-231-7589"]
   ])
)
])
