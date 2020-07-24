with (import <nixpkgs> { overlays = import ../conix.nix; }).conix; 

build.pdfFile "readme" (texts [ "readme" ] [ '' 

  builders.pdf.build (page "Volunteers" (pages: [(text '''
    # Volunteer Handbook

    ## Emergency Plan

    Incase of an emergency please contact: ''${pages.Volunteers.contacts.Jingle.Name} at ''${pages.Volunteers.contacts.Jingle.Phone}

    ## Volunteer Contacts 

    We still need ''${8 - (builtins.length pages.Volunteers.contacts.rows)} volunteers. 

    ''')
    (table "contacts" 
      { header = ["Name"   "Phone" ];
        rows  = [["John"   "555-123-4563"]
                 ["Jacob"  "555-321-9872"]
                 ["Jingle" "555-231-7589"]
                ];
      }
    )
    (text '''

    ''')
  ]))
