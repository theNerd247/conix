with (import <nixpkgs> { overlays = import ../conix.nix; }).conix; 

build.pdfFile "Volunteers" textsWith (pages: [ (t '' 

    # Volunteer Handbook

    ## Emergency Plan

    Incase of an emergency please contact: Jingle at
    ${pages.Volunteers.contacts.Jingle.Phone}

    ## Volunteer Contacts 

    We still need ${8 - (builtins.length pages.Volunteers.contacts.rows.length)} 
    volunteers. 

    '')
    (table [ "contacts" ]
        ["Name"   "Phone" ]
       [["John"   "555-123-4563"]
        ["Jacob"  "555-321-9872"]
        ["Jingle" "555-231-7589"]
       ]
    )
])
