let
  refDir = ./.git/refs/heads;
  refFile = ./.git/HEAD;
  refName = builtins.replaceStrings ["ref: refs/heads/" "\n"] ["" ""]  (builtins.readFile refFile);

  # If the ref is 40 characters long then it's most likely a hash
  # in which case we're in a detached head state and are unable to point
  # to a ref - so we'll do without...
  isHeadless = builtins.stringLength refName == 40; 
  rev = if isHeadless 
    then refName
    else
      builtins.replaceStrings ["\n"] [""] 
        (builtins.readFile "${refDir}/${refName}");

  ref = if isHeadless then "HEAD" else refName;
in
rec
{
  url = "https://github.com/theNerd247/conix.git"; 
  inherit rev ref;
}
