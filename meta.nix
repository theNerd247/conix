self: super:

with super.conix;

{ conix = (super.conix or {}) //
  rec
  { 
    homepageUrl = "https://github.com/theNerd247/conix.git";
    gitHttpUrl = "https://github.com/theNerd247/conix.git"; 
    homePageLink = "<a href=\"${homepageUrl.val}\">conix</a>";
    buildStatusBadgeMd = "![CI](https://github.com/theNerd247/conix/workflows/CI/badge.svg?branch=master)";
    version = rec  
      { text = "${builtins.toString major}.${builtins.toString minor}.${builtins.toString patch}";
        major = 0; 
        minor = 1; 
        patch = 0; 
      };

    lib = super.conix.extendLib super.conix.lib (x:
      { inherit
        homepageUrl
        gitHttpUrl
        homePageLink
        buildStatusBadgeMd
        version;
      }
    );
  };
}
