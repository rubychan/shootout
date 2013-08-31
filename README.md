# shootout

…benchmarks different syntax highlighter libraries, namely:

- [CodeRay](https://github.com/rubychan/coderay)
- [Rouge](https://github.com/jayferd/rouge)
- [Albino](https://github.com/github/albino)
- [Pygments.rb](https://github.com/tmm1/pygments.rb)
- [Pygments](https://bitbucket.org/birkenfeld/pygments-main)
- [Highlight](http://www.andre-simon.de/doku/highlight/en/highlight.html)

Feel free to add more libraries by writing an [adapter](https://github.com/rubychan/shootout/tree/master/adapters)!

## Install

Make sure you have Ruby 2.0 and Python installed.

`git clone https://github.com/rubychan/shootout.git` to get the code.

Then, run `bundle` to install the necessary Gems.

Optional: Install [Pygments](http://pygments.org/) and [Highlight](http://www.andre-simon.de/doku/highlight/en/highlight.html).

### OS X

```
[sudo] easy_install pygments
brew install highlight
```

### more systems

Please add instructions for your system.

## Run

To run the benchmark, just run `rake`. It takes a few minutes to get this:

```
                       Welcome to
  ~~~ The Great Syntax Highlighter Shootout v1.1 ~~~

using Ruby 2.0.0 and Python 2.7.5, repeating 2 times

                  CodeRay 1.0.9         Rouge 0.4.0        Albino 1.3.3   Pygments.rb 0.5.2      pygmentize 1.6      highlight 3.14
   C (218 kB)
=> text               2674 kB/s            146 kB/s            267 kB/s            290 kB/s            265 kB/s                    
=> terminal           1291 kB/s            140 kB/s            189 kB/s            205 kB/s            186 kB/s            792 kB/s
=> html               1385 kB/s            124 kB/s            199 kB/s            220 kB/s            200 kB/s            785 kB/s

HTML (218 kB)
=> text               2446 kB/s            252 kB/s            761 kB/s           1046 kB/s            765 kB/s                    
=> terminal            380 kB/s            238 kB/s            437 kB/s            524 kB/s            426 kB/s           1036 kB/s
=> html                690 kB/s            190 kB/s            479 kB/s            595 kB/s            457 kB/s           1036 kB/s

JSON (217 kB)
=> text               2832 kB/s            238 kB/s            637 kB/s            850 kB/s            641 kB/s                    
=> terminal            746 kB/s            226 kB/s            354 kB/s            402 kB/s            347 kB/s            539 kB/s
=> html                821 kB/s            173 kB/s            390 kB/s            467 kB/s            390 kB/s            533 kB/s

RUBY (216 kB)
=> text               3402 kB/s            273 kB/s            330 kB/s            395 kB/s            324 kB/s                    
=> terminal           1009 kB/s            265 kB/s            267 kB/s            320 kB/s            266 kB/s            561 kB/s
=> html               2174 kB/s            246 kB/s            278 kB/s            309 kB/s            278 kB/s            544 kB/s

TEXT (0 kB)
=> text                246 kB/s            698 kB/s              0 kB/s             39 kB/s              0 kB/s                    
=> terminal            296 kB/s            353 kB/s              0 kB/s             59 kB/s              0 kB/s              3 kB/s
=> html                 23 kB/s            714 kB/s              0 kB/s             27 kB/s              0 kB/s              3 kB/s
```

## Configure

You can adjust the benchmark using these environment variables:

- `SHOOTERS`: A list of libraries that you want to test against each other. Defaults to all ones.
- `LANGUAGES`: A list of input languages. Defaults to all languages in the `example-code` folder.
- `FORMATS`: A list of output formats/encoders. Defaults to `text`, `terminal`, and `html`. `null` is also available for some highlighters, and is supposed to measure scanner/lexer time only.
- `REPEATS`: The accuracy: How many times each test is repeated. The result is the average speed of all runs. Defaults to 2.
- `METRIC=time`: Show measured times instead of speed.
- `SIZE`: The size of the input, in bytes. Defaults to the size of the example files.

If you want to use a different version of an installed gem, you can set it with `ROUGE=0.3.5` _before_ the `rake`.

Example:

```bash
CODERAY=1.1.0.rc5 rake REPEATS=1 SHOOTERS="CodeRay Highlight" LANGUAGES=html FORMATS="null html"
```

outputs:

```
                       Welcome to
  ~~~ The Great Syntax Highlighter Shootout v1.1 ~~~

using Ruby 2.0.0 and Python 2.7.5, repeating 1 times

                  CodeRay 1.1.0      highlight 3.14
HTML (1091 kB)
=> null               3015 kB/s                    
=> html                791 kB/s           1160 kB/s
```
## License

This is free and unencumbered software released into the public domain (see LICENSE).
