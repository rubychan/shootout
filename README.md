# shootout [![CodeFactor](https://www.codefactor.io/repository/github/rubychan/shootout/badge/master)](https://www.codefactor.io/repository/github/rubychan/shootout/overview/master)

![screenshot_05](https://cloud.githubusercontent.com/assets/1037292/6815049/68c09fda-d285-11e4-8df4-c7ffc2b6fd29.jpg)

…benchmarks different syntax highlighter libraries, namely:

- [CodeRay](https://github.com/rubychan/coderay)
- [Rouge](https://github.com/jayferd/rouge)
- [Pygments.rb](https://github.com/tmm1/pygments.rb)
- [Albino](https://github.com/github/albino) (optional)
- [Pygments](https://bitbucket.org/birkenfeld/pygments-main) (optional)
- [Highlight](http://www.andre-simon.de/doku/highlight/en/highlight.html) (optional)

Feel free to add more libraries by writing an [adapter](https://github.com/rubychan/shootout/tree/master/adapters)!


## Install

Make sure you have Ruby 2+ and Python 3 installed.

`git clone https://github.com/rubychan/shootout.git` to get the code.

Then, run `bundle` to install the necessary Gems.


## Additional highlighters

You need to have [Pygments](http://pygments.org/) and [Highlight](http://www.andre-simon.de/doku/highlight/en/highlight.html) installed to test them.

### …on OS X

```
[sudo] easy_install pygments
brew install highlight
```

Add `SHOOTERS=all` when running the benchmark, because they are not included in the benchmark by default.

### more systems

Please add instructions for your system.


## Run

To run the benchmark, just run `rake`. It takes a few minutes to get this:

```
                       Welcome to
  ~~~ The Great Syntax Highlighter Shootout v1.7 ~~~

using Ruby 2.3.0 and Python 2.7.11, repeating 5 times

                  CodeRay 1.1.1        Rouge 1.10.1   Pygments.rb 0.6.3
C (218 kB)
=> terminal           3862 kB/s            474 kB/s            314 kB/s
=> html               2594 kB/s            474 kB/s            320 kB/s

CSS (218 kB)
=> terminal           2973 kB/s            935 kB/s            475 kB/s
=> html               2157 kB/s            959 kB/s            545 kB/s

HTML (218 kB)
=> terminal           3108 kB/s           1496 kB/s            873 kB/s
=> html               1388 kB/s           1147 kB/s            983 kB/s

JAVASCRIPT (218 kB)
=> terminal           3008 kB/s            457 kB/s            433 kB/s
=> html               2217 kB/s            459 kB/s            488 kB/s

JSON (217 kB)
=> terminal           2546 kB/s            734 kB/s            550 kB/s
=> html               1539 kB/s           1145 kB/s            761 kB/s

LUA (244 kB)
=> terminal           1859 kB/s            743 kB/s            353 kB/s
=> html               1411 kB/s            749 kB/s            414 kB/s

PERL (217 kB)
=> terminal                                514 kB/s            383 kB/s
=> html                                    517 kB/s            395 kB/s

RUBY (216 kB)
=> terminal           5174 kB/s            990 kB/s            459 kB/s
=> html               4064 kB/s            989 kB/s            461 kB/s
-----------------------------------------------------------------------
Total score           2707 kB/s            799 kB/s            513 kB/s
Relative                                    29.51 %             18.95 %
```

## Configure

You can adjust the benchmark using these environment variables:

- `SHOOTERS`: A list of libraries that you want to test against each other. Available are: `CodeRay`, `CodeRayExe`, `Rouge`, `Rougify`, `Albino`, `Pygments.rb`, `Pygmentize`, and `Highlight`. Set to `all` to benchmark all of them. Defaults to `"CodeRay Rouge Pygments.rb"`.
- `LANGUAGES`: A list of input languages. Defaults to all languages in the `example-code` folder.
- `FORMATS`: A list of output formats/encoders. Defaults to `"terminal html"`. `text` and `null` are also available for some highlighters, and are supposed to measure scanner/lexer time only.
- `REPEATS`: The accuracy: How many times each test is repeated. The result is the average speed of all runs. Defaults to 5.
- `METRIC=time`: Show measured times instead of speed.
- `METRIC=diff`: Show relative scores. The first result is 100%.
- `SIZES`: The sizes of the inputs, in bytes. For negative numbers, the example files are taken as is. For positive numbers, inputs are cut after the given number of bytes. The value can be a single integer (`42`), a list (`[100, 200, 300, -1]`), or any other Ruby expression returning a list of integers (`500.step(10000, 500)`). Defaults to `-1` (no cutting).
- `GC=disable`: Don't use the Ruby garbage collector during benchmarks. This may or may not give you more predictable results.

Additionally, you can configure which versions to use:

- If you want to use a different version of an installed gem, you can set it like `ROUGE=0.5.0` or `CODERAY=1.0.9`.
- If you want to use a local checkout, set them like `LOCAL_ROUGE=/path/to/rouge` or `LOCAL_CODERAY=../coderay`.
- Both options will also affect the executable shooters (Rougify and CodeRayExe).
- Both options must be give _before_ the `rake` to affect bundler.

Example:

```bash
CODERAY=1.0.9 rake REPEATS=1 SHOOTERS="CodeRay Rouge" LANGUAGES=html FORMATS="text html"
```

outputs:

```
                       Welcome to
  ~~~ The Great Syntax Highlighter Shootout v1.6 ~~~

using Ruby 2.0.0 and Python 2.7.5, repeating 1 times

                  CodeRay 1.0.9         Rouge 1.1.0
HTML (218 kB)
=> text               2183 kB/s            344 kB/s
=> html                697 kB/s            242 kB/s
---------------------------------------------------
Total score           1440 kB/s            293 kB/s
```

## License

This is free and unencumbered software released into the public domain (see LICENSE).
