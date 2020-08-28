conix: { lib = rec
  { 
    homepageUrl = "https://theNerd247.github.io/conix";
    homePageLink = "<a href=\"${homepageUrl}\">conix</a>";
    buildBadgeLink = "![](https://travis-ci.com/theNerd247/conix.svg?branch=${conix.lib.git.ref})";
    version = rec  
      { text = "${builtins.toString major}.${builtins.toString minor}.${builtins.toString patch}";
        major = 0; 
        minor = 1; 
        patch = 0; 
      };
  };
}
