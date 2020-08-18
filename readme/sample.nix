(import <nixpkgs> { 
  overlays = import (builtins.fetchGit
    { url = "https://github.com/theNerd247/conix.git"; 
      rev = "b412557b7f9ed3707994a867453d66308446e064";
      ref = "v0.1.0-api";
    }
  );
}).conix.build 
(conix: { data = with conix.lib; using (markdownFile "Volunteers") (texts [

''# Volunteer Handbook

## Emergency Plan

Incase of an emergency please contact: ''
(t (conix.data.contacts.at 2 0))" at "(t (conix.data.contacts.at 2 1))''.

## Volunteer Contacts 

_Volunteers still needed!: ''(t (8 - (builtins.length conix.data.contacts.data)))''_
''
(set "contacts" (table
    ["Name" "Phone" ]
  [ ["John"   "555-123-4563"]
    ["Jacob"  "555-321-9872"]
    ["Jingle" "555-231-7589"]
  ]
))
]); })
