self: super:

with super.conix;

{ conix = (super.conix or {}) //
  rec
  { 
    homepageUrl = pureModule "https://github.com/theNerd247/conix.git";
    homePageLink = pureModule "<a href=\"${homepageUrl.val}\">conix</a>";
    buildStatusBadgeMd = pureModule "![CI](https://github.com/theNerd247/conix/workflows/CI/badge.svg?branch=master)";
    version = rec  
      { text = pureModule "${builtins.toString major}.${builtins.toString minor}.${builtins.toString patch}";
        major = 0; 
        minor = 1; 
        patch = 0; 
      };
  };
}
