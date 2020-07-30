self: super:

with super.conix;

{ conix = (super.conix or {}) //
  rec
  { 
    homepageUrl = pureModule "https://github.com/theNerd247/conix.git";
    conixHttpLink = pureModule "<a href=\"${homepageUrl}\">conix</a>";
    version = rec  
      { text = "${builtins.toString major}.${builtins.toString minor}.${builtins.toString patch}";  
        major = 0; 
        minor = 0; 
        patch = 2; 
      };
  };
}
