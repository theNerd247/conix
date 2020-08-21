let
  refDir = ./.git/refs/heads;
  refFile = ./.git/HEAD;
in
rec
{
  url = "https://github.com/theNerd247/conix.git"; 
  ref = builtins.replaceStrings ["ref: refs/heads/" "\n"] ["" ""]  (builtins.readFile refFile);
  rev = 
    # If the ref is 40 characters long then it's most likely a hash
    # in which case we're in a detached head state and are unable to point
    # to a ref - so we'll do without...
    if builtins.stringLength ref == 40 then ""
    else
      builtins.replaceStrings ["\n"] [""] 
        (builtins.readFile "${refDir}/${ref}");
}
