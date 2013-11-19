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
  ~~~ The Great Syntax Highlighter Shootout v1.4 ~~~

using Ruby 2.0.0 and Python 2.7.5, repeating 5 times

                  CodeRay 1.1.0         Rouge 1.1.0   Pygments.rb 0.5.4
   C (218 kB)
=> terminal           2147 kB/s            136 kB/s            204 kB/s
=> html               1398 kB/s            122 kB/s            218 kB/s

HTML (218 kB)
=> terminal           1462 kB/s            318 kB/s            513 kB/s
=> html                682 kB/s            238 kB/s            581 kB/s

JSON (217 kB)
=> terminal           1729 kB/s            293 kB/s            398 kB/s
=> html                801 kB/s            223 kB/s            455 kB/s

RUBY (216 kB)
=> terminal           2887 kB/s            303 kB/s            316 kB/s
=> html               2183 kB/s            276 kB/s            321 kB/s
```

## Configure

You can adjust the benchmark using these environment variables:

- `SHOOTERS`: A list of libraries that you want to test against each other. Available are: `CodeRay`, `CodeRayExe`, `Rouge`, `Rougify`, `Albino`, `Pygments.rb`, `Pygmentize`, and `Highlight`. Defaults to `"CodeRay Rouge Pygments.rb"`.
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
