# shootout [![CodeFactor](https://www.codefactor.io/repository/github/rubychan/shootout/badge/master)](https://www.codefactor.io/repository/github/rubychan/shootout/overview/master)

![screenshot_05](https://cloud.githubusercontent.com/assets/1037292/6815049/68c09fda-d285-11e4-8df4-c7ffc2b6fd29.jpg)

…benchmarks different syntax highlighter libraries, namely:

- [CodeRay](https://github.com/rubychan/coderay)
- [Rouge](https://github.com/jayferd/rouge)
- [Pygments.rb](https://github.com/tmm1/pygments.rb)
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
  ~~~ The Great Syntax Highlighter Shootout v1.8 ~~~

using Ruby 3.2.6 and Python 3.13.0, repeating 5 times

                  CodeRay 1.1.3         Rouge 4.4.0   Pygments.rb 3.0.0
C (218 kB)
=> terminal           8197 kB/s            809 kB/s            947 kB/s
=> html               5794 kB/s            867 kB/s            959 kB/s

CSS (218 kB)
=> terminal           5484 kB/s           1485 kB/s           1925 kB/s
=> html               4646 kB/s           1829 kB/s           2331 kB/s

HTML (218 kB)
=> terminal           5903 kB/s           2016 kB/s           2902 kB/s
=> html               3474 kB/s           1989 kB/s           3218 kB/s

JAVASCRIPT (218 kB)
=> terminal           5447 kB/s            143 kB/s           1244 kB/s
=> html               4737 kB/s            144 kB/s           1288 kB/s

JSON (217 kB)
=> terminal           6514 kB/s           1700 kB/s           3822 kB/s
=> html               4060 kB/s           1935 kB/s           5296 kB/s

LUA (244 kB)
=> terminal           3973 kB/s           1214 kB/s           2309 kB/s
=> html               3452 kB/s           1339 kB/s           2342 kB/s

PERL (217 kB)
=> terminal                                759 kB/s           1321 kB/s
=> html                                    802 kB/s           1346 kB/s

RUBY (216 kB)
=> terminal          11352 kB/s           1667 kB/s           1589 kB/s
=> html               8707 kB/s           1752 kB/s           1645 kB/s
-----------------------------------------------------------------------
Total score           5839 kB/s           1278 kB/s           2155 kB/s
Relative                                    21.89 %             36.91 %
```

## Configure

You can adjust the benchmark using these environment variables:

- `SHOOTERS`: A list of libraries that you want to test against each other. Available are: `CodeRay`, `CodeRayExe`, `Rouge`, `Rougify`, `Pygments.rb`, `Pygmentize`, and `Highlight`. Set to `all` to benchmark all of them. Defaults to `"CodeRay Rouge Pygments.rb"`.
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
  ~~~ The Great Syntax Highlighter Shootout v1.8 ~~~

using Ruby 3.2.6 and Python 3.13.0, repeating 1 times

                  CodeRay 1.0.9         Rouge 4.4.0
HTML (218 kB)
=> text               7927 kB/s           2718 kB/s
=> html               3501 kB/s           1933 kB/s
---------------------------------------------------
Total score           5714 kB/s           2325 kB/s
Relative                                    40.70 %
```

## License

This is free and unencumbered software released into the public domain (see LICENSE).
