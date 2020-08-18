conix: { lib = rec
  { 
    homepageUrl = "https://github.com/theNerd247/conix.git";
    homePageLink = "<a href=\"${homepageUrl.val}\">conix</a>";
    buildStatusBadgeMd = "![CI](https://github.com/theNerd247/conix/workflows/CI/badge.svg?branch=master)";
    version = rec  
      { text = "${builtins.toString major}.${builtins.toString minor}.${builtins.toString patch}";
        major = 0; 
        minor = 1; 
        patch = 0; 
      };
  };
}
