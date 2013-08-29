# shootout

…benchmarks different syntax highlighter libraries.

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

To run the benchmark, just run `rake`. It takes 2-5 minutes to get this:

```
                       Welcome to
  ~~~ The Great Syntax Highlighter Shootout v1.0 ~~~

using Ruby 2.0.0 and Python 2.7.5, repeating 2 times

                  CodeRay 1.0.9         Rouge 0.4.0      pygmentize 1.6      Pygments 0.5.2        Albino 1.3.3      highlight 3.14
HTML (1091 kB)
=> text               2630 kB/s            274 kB/s            939 kB/s           1028 kB/s           1030 kB/s                    
=> terminal            462 kB/s            259 kB/s            489 kB/s            509 kB/s            487 kB/s           1148 kB/s
=> html                766 kB/s            209 kB/s            243 kB/s            246 kB/s            245 kB/s           1128 kB/s

JSON (217 kB)
=> text               3132 kB/s            268 kB/s            641 kB/s            820 kB/s            659 kB/s                    
=> terminal            922 kB/s            253 kB/s            336 kB/s            401 kB/s            349 kB/s            528 kB/s
=> html                892 kB/s            203 kB/s            313 kB/s            340 kB/s            389 kB/s            514 kB/s

RUBY (353 kB)
=> text               2620 kB/s            206 kB/s            247 kB/s            265 kB/s            249 kB/s                    
=> terminal            928 kB/s            200 kB/s            199 kB/s            217 kB/s            208 kB/s            491 kB/s
=> html               1643 kB/s            185 kB/s            200 kB/s            214 kB/s            202 kB/s            489 kB/s
```

## Configure

You can adjust the benchmark using these environment variables:

- `SHOOTERS`: A list of libraries that you want to test against each other. Defaults to all ones.
- `LANGUAGES`: A list of input languages. Defaults to all languages in the `example-code` folder.
- `FORMATS`: A list of output formats/encoders. Defaults to `text`, `terminal`, and `html`. `null` is also available.
- `REPEATS`: The accuracy: How many times each test is repeated. The result is the average speed of all runs. Defaults to 2.

If you want to use a different version of an installed gem, you can set it like `ROUGE=0.3.5` _before_ the `rake`.

Example:

```bash
CODERAY=1.1.0.rc4 rake N=1 SHOOTERS="CodeRay Highlight" LANGUAGES=html FORMATS="null html"
```

outputs:

```

                       Welcome to
  ~~~ The Great Syntax Highlighter Shootout v1.0 ~~~

using Ruby 2.0.0 and Python 2.7.5, repeating 2 times

                  CodeRay 1.1.0      highlight 3.14
HTML (1091 kB)
=> null               3015 kB/s                    
=> html                791 kB/s           1160 kB/s
```
## License

This is free and unencumbered software released into the public domain (see LICENSE).
