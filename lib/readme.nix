x: with x; _use (exprs.markdown "readme" [

  (exprs.meta [
    (exprs.css exprs.conixCss)
    (exprs.pagetitle (_ask data.index.title))
  ])

"# "(_ask data.index.title)''


''(_ask data.intro)''

# Documentation

  * [Conix Home Page](''(exprs.conix.homepageUrl)'')

''(_ask data.gettingStartedText)''

# Contributing

Any ideas or help are welcome! Please submit a PR or open an issue as you see
fit. I like to use the project board to organize my thoughts; check the todo
column for tasks to work on. I will try and convert these to issues when I can.

# Related Works

* [Pollen](https://docs.racket-lang.org/pollen/) - _"Pollen is a publishing
system that helps authors make functional and beautiful digital books."_

# Acknowledgements

Many thanks to:

  * [Gabriel Gonzalez](https://github.com/Gabriel439)
  * [Evan Relf](https://github.com/evanrelf)
  * [Paul Young](https://github.com/paulyoung)
''])
