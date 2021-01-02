(import <nixpkgs> { overlays = import (builtins.fetchGit 
{ ref = "master"; rev = "3d63e3087f69b379be0cd5efbf56c28c7bf79b69"; url = "https://github.com/theNerd247/conix.git"; }); 
}).conix.run(conix: with conix;


markdown "readme" (html "readme" ''

# My Readme

This is a readme file!

''))

