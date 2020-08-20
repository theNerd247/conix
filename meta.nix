conix: { lib = rec
  { 
    homepageUrl = "https://github.com/theNerd247/conix.git";
    homePageLink = "<a href=\"${homepageUrl}\">conix</a>";
    buildStatusBadgeMd = "![CI](https://travis-ci.com/theNerd247/conix.svg?branch=${conix.lib.git.ref})";
    version = rec  
      { text = "${builtins.toString major}.${builtins.toString minor}.${builtins.toString patch}";
        major = 0; 
        minor = 1; 
        patch = 0; 
      };
  };
}
