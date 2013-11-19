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

                  CodeRay 1.1.0         Rouge 1.1.0        Albino 1.3.3   Pygments.rb 0.5.4      pygmentize 1.6      highlight 3.14
   C (218 kB)
=> text               2311 kB/s            139 kB/s            261 kB/s            291 kB/s            259 kB/s                    
=> terminal           2056 kB/s            134 kB/s            189 kB/s            202 kB/s            188 kB/s            784 kB/s
=> html               1233 kB/s            119 kB/s            201 kB/s            220 kB/s            200 kB/s            779 kB/s

HTML (218 kB)
=> text               2338 kB/s            328 kB/s            734 kB/s           1059 kB/s            760 kB/s                    
=> terminal           1398 kB/s            308 kB/s            431 kB/s            517 kB/s            427 kB/s           1005 kB/s
=> html                627 kB/s            226 kB/s            475 kB/s            578 kB/s            467 kB/s           1031 kB/s

JSON (217 kB)
=> text               2622 kB/s            316 kB/s            626 kB/s            858 kB/s            619 kB/s                    
=> terminal           1589 kB/s            289 kB/s            354 kB/s            403 kB/s            342 kB/s            544 kB/s
=> html                737 kB/s            216 kB/s            384 kB/s            457 kB/s            392 kB/s            538 kB/s

RUBY (216 kB)
=> text               3338 kB/s            306 kB/s            328 kB/s            384 kB/s            326 kB/s                    
=> terminal           2515 kB/s            295 kB/s            272 kB/s            317 kB/s            266 kB/s            543 kB/s
=> html               1840 kB/s            261 kB/s            278 kB/s            321 kB/s            274 kB/s            558 kB/s
```

## Configure

You can adjust the benchmark using these environment variables:

- `SHOOTERS`: A list of libraries that you want to test against each other. Defaults to `"CodeRay Rouge Albino Pygments.rb Pygmentize Highlight"`.
- `LANGUAGES`: A list of input languages. Defaults to all languages in the `example-code` folder.
- `FORMATS`: A list of output formats/encoders. Defaults to `text`, `terminal`, and `html`. `null` is also available for some highlighters, and is supposed to measure scanner/lexer time only.
- `REPEATS`: The accuracy: How many times each test is repeated. The result is the average speed of all runs. Defaults to 2.
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
CODERAY=1.0.9 rake REPEATS=1 SHOOTERS="CodeRay Highlight" LANGUAGES=html FORMATS="null html"
```

outputs:

```
                       Welcome to
  ~~~ The Great Syntax Highlighter Shootout v1.1 ~~~

using Ruby 2.0.0 and Python 2.7.5, repeating 1 times

                  CodeRay 1.0.9      highlight 3.14
HTML (218 kB)
=> null               2629 kB/s                    
=> html                690 kB/s           1003 kB/s
```

## License

This is free and unencumbered software released into the public domain (see LICENSE).
