# shootout

…benchmarks different syntax highlighter libraries, namely:

- [CodeRay](https://github.com/rubychan/coderay)
- [Rouge](https://github.com/jayferd/rouge)
- [Pygments.rb](https://github.com/tmm1/pygments.rb)
- [Albino](https://github.com/github/albino) (optional)
- [Pygments](https://bitbucket.org/birkenfeld/pygments-main) (optional)
- [Highlight](http://www.andre-simon.de/doku/highlight/en/highlight.html) (optional)

Feel free to add more libraries by writing an [adapter](https://github.com/rubychan/shootout/tree/master/adapters)!


## Install

Make sure you have Ruby 2.0 and Python installed.

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
  ~~~ The Great Syntax Highlighter Shootout v1.6 ~~~

using Ruby 2.0.0 and Python 2.7.5, repeating 5 times

                  CodeRay 1.1.0         Rouge 1.1.0   Pygments.rb 0.5.4
C (218 kB)
=> terminal           2237 kB/s            139 kB/s            204 kB/s
=> html               1420 kB/s            124 kB/s            217 kB/s

CSS (218 kB)
=> terminal           1655 kB/s            254 kB/s            313 kB/s
=> html               1203 kB/s            211 kB/s            347 kB/s

HTML (218 kB)
=> terminal           1480 kB/s            316 kB/s            518 kB/s
=> html                681 kB/s            241 kB/s            575 kB/s

JAVASCRIPT (218 kB)
=> terminal           1456 kB/s            170 kB/s            255 kB/s
=> html               1057 kB/s            150 kB/s            280 kB/s

JSON (217 kB)
=> terminal           1781 kB/s            298 kB/s            396 kB/s
=> html                794 kB/s            224 kB/s            456 kB/s

PERL (217 kB)
=> terminal                                157 kB/s            255 kB/s
=> html                                    143 kB/s            268 kB/s

RUBY (216 kB)
=> terminal           2780 kB/s            306 kB/s            314 kB/s
=> html               2081 kB/s            277 kB/s            320 kB/s
-----------------------------------------------------------------------
Total score           1552 kB/s            215 kB/s            337 kB/s
```

## Configure

You can adjust the benchmark using these environment variables:

- `SHOOTERS`: A list of libraries that you want to test against each other. Available are: `CodeRay`, `CodeRayExe`, `Rouge`, `Rougify`, `Albino`, `Pygments.rb`, `Pygmentize`, and `Highlight`. Set to `all` to benchmark all of them. Defaults to `"CodeRay Rouge Pygments.rb"`.
- `LANGUAGES`: A list of input languages. Defaults to all languages in the `example-code` folder.
- `FORMATS`: A list of output formats/encoders. Defaults to `"terminal html"`. `text` and `null` are also available for some highlighters, and are supposed to measure scanner/lexer time only.
- `REPEATS`: The accuracy: How many times each test is repeated. The result is the average speed of all runs. Defaults to 5.
- `METRIC=time`: Show measured times instead of speed.
- `SIZES`: The sizes of the inputs, in bytes. For negative numbers, the example files are taken as is. For positive numbers, inputs are cut after the given number of bytes. The value be a single integer (`42`), a list (`[100, 200, 300, -1]`), or any other Ruby expression returning a list of integers (`500.step(10000, 500)`). Defaults to `-1` (no cutting).
- `GC`: Whether to use the Ruby garbage collector during benchmarks. This may or may not give you more predictable results. Set to `disabled` to disable the GC. Defaults to `enable`.

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
