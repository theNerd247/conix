let
  refDir = ./.git/refs/heads;
  refFile = ./.git/HEAD;
  ref = builtins.replaceStrings ["ref: refs/heads/" "\n"] ["" ""] (builtins.readFile refFile);

  # If the ref is 40 characters long then it's most likely a hash
  # in which case we're in a detached head state and are unable to point
  # to a ref - so we'll do without...
  rev = if builtins.stringLength ref == 40 
    then throw 
      ''
      You're in a HEADLESS git state and conix can't determine which branch to
      use for the "ref" value in builtins.fetchgit. Please checkout a branch
      and retry the build. Also, check to make sure that the branch you're
      building has been pushed to github.  ''
    else
      builtins.replaceStrings ["\n"] [""] 
        (builtins.readFile "${refDir}/${ref}");
in
{ conix =
  { 
    homepageUrl = "https://github.com/theNerd247/conix.git";
    homePageLink = "<a href=\"${homepageUrl}\">conix</a>";
    buildBadgeLink = "![](https://travis-ci.com/theNerd247/conix.svg?branch=${ref})";
    git =
      {
        url = "https://github.com/theNerd247/conix.git"; 
        inherit rev ref;
      };
    version = rec  
      { text = "${builtins.toString major}.${builtins.toString minor}.${builtins.toString patch}";
        major = 0; 
        minor = 1; 
        patch = 0; 
      };
  };
}