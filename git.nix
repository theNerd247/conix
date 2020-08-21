rec
{
  refDir = ./.git/refs/heads;
  refFile = ./.git/HEAD;
  url = "https://github.com/theNerd247/conix.git"; 
  ref = builtins.replaceStrings ["ref: refs/heads/" "\n"] ["" ""]  (builtins.readFile refFile);
  rev = builtins.replaceStrings ["\n"] [""] (builtins.readFile "${refDir}/${ref}");
}
