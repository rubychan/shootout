# -*- perl -*-

# ^^PLEAC^^_NAME
Perl

# ^^PLEAC^^_WEB
http://www.perl.org/

# ^^PLEAC^^_1.0
#-----------------------------
$string = '\n';                     # two characters, \ and an n
$string = 'Jon \'Maddog\' Orwant';  # literal single quotes
#-----------------------------
$string = "\n";                     # a "newline" character
$string = "Jon \"Maddog\" Orwant";  # literal double quotes
#-----------------------------
$string = q/Jon 'Maddog' Orwant/;   # literal single quotes
#-----------------------------
$string = q[Jon 'Maddog' Orwant];   # literal single quotes
$string = q{Jon 'Maddog' Orwant};   # literal single quotes
$string = q(Jon 'Maddog' Orwant);   # literal single quotes
$string = q<Jon 'Maddog' Orwant>;   # literal single quotes
#-----------------------------
$a = <<"EOF";
This is a multiline here document
terminated by EOF on a line by itself
EOF
#-----------------------------

# ^^PLEAC^^_1.1
#-----------------------------
$value = substr($string, $offset, $count);
$value = substr($string, $offset);

substr($string, $offset, $count) = $newstring;
substr($string, $offset)         = $newtail;
#-----------------------------
# get a 5-byte string, skip 3, then grab 2 8-byte strings, then the rest
($leading, $s1, $s2, $trailing) =
    unpack("A5 x3 A8 A8 A*", $data);

# split at five byte boundaries
@fivers = unpack("A5" x (length($string)/5), $string);

# chop string into individual characters
@chars  = unpack("A1" x length($string), $string);
#-----------------------------
$string = "This is what you have";
#         +012345678901234567890  Indexing forwards  (left to right)
#          109876543210987654321- Indexing backwards (right to left)
#           note that 0 means 10 or 20, etc. above

$first  = substr($string, 0, 1);  # "T"
$start  = substr($string, 5, 2);  # "is"
$rest   = substr($string, 13);    # "you have"
$last   = substr($string, -1);    # "e"
$end    = substr($string, -4);    # "have"
$piece  = substr($string, -8, 3); # "you"
#-----------------------------
$string = "This is what you have";
print $string;
#This is what you have

substr($string, 5, 2) = "wasn't"; # change "is" to "wasn't"
#This wasn't what you have

substr($string, -12)  = "ondrous";# replace last 12 characters
#This wasn't wondrous

substr($string, 0, 1) = "";       # delete first character
#his wasn't wondrous

substr($string, -10)  = "";       # delete last 10 characters
#his wasn'
#-----------------------------
# you can test substrings with =~
if (substr($string, -10) =~ /pattern/) {
    print "Pattern matches in last 10 characters\n";
}

# substitute "at" for "is", restricted to first five characters
substr($string, 0, 5) =~ s/is/at/g;
#-----------------------------
# exchange the first and last letters in a string
$a = "make a hat";
(substr($a,0,1), substr($a,-1)) = (substr($a,-1), substr($a,0,1));
print $a;
# take a ham
#-----------------------------
# extract column with unpack
$a = "To be or not to be";
$b = unpack("x6 A6", $a);  # skip 6, grab 6
print $b;
# or not

($b, $c) = unpack("x6 A2 X5 A2", $a); # forward 6, grab 2; backward 5, grab 2
print "$b\n$c\n";
# or
#
# be
#-----------------------------
sub cut2fmt {
    my(@positions) = @_;
    my $template   = '';
    my $lastpos    = 1;
    foreach $place (@positions) {
        $template .= "A" . ($place - $lastpos) . " ";
        $lastpos   = $place;
    }
    $template .= "A*";
    return $template;
}

$fmt = cut2fmt(8, 14, 20, 26, 30);
print "$fmt\n";
# A7 A6 A6 A6 A4 A*
#-----------------------------

# ^^PLEAC^^_1.2
#-----------------------------
# use $b if $b is true, else $c
$a = $b || $c;              

# set $x to $y unless $x is already true
$x ||= $y
#-----------------------------
# use $b if $b is defined, else $c
$a = defined($b) ? $b : $c;
#-----------------------------
$foo = $bar || "DEFAULT VALUE";
#-----------------------------
$dir = shift(@ARGV) || "/tmp";
#-----------------------------
$dir = $ARGV[0] || "/tmp";
#-----------------------------
$dir = defined($ARGV[0]) ? shift(@ARGV) : "/tmp";
#-----------------------------
$dir = @ARGV ? $ARGV[0] : "/tmp";
#-----------------------------
$count{ $shell || "/bin/sh" }++;
#-----------------------------
# find the user name on Unix systems
$user = $ENV{USER}
     || $ENV{LOGNAME}
     || getlogin()
     || (getpwuid($<))[0]
     || "Unknown uid number $<";
#-----------------------------
$starting_point ||= "Greenwich";
#-----------------------------
@a = @b unless @a;          # copy only if empty
@a = @b ? @b : @c;          # assign @b if nonempty, else @c
#-----------------------------

# ^^PLEAC^^_1.3
#-----------------------------
($VAR1, $VAR2) = ($VAR2, $VAR1);
#-----------------------------
$temp    = $a;
$a       = $b;
$b       = $temp;
#-----------------------------
$a       = "alpha";
$b       = "omega";
($a, $b) = ($b, $a);        # the first shall be last -- and versa vice
#-----------------------------
($alpha, $beta, $production) = qw(January March August);
# move beta       to alpha,
# move production to beta,
# move alpha      to production
($alpha, $beta, $production) = ($beta, $production, $alpha);
#-----------------------------

# ^^PLEAC^^_1.4
#-----------------------------
$num  = ord($char);
$char = chr($num);
#-----------------------------
$char = sprintf("%c", $num);                # slower than chr($num)
printf("Number %d is character %c\n", $num, $num);
Number 101 is character e
#-----------------------------
@ASCII = unpack("C*", $string);
$STRING = pack("C*", @ascii);
#-----------------------------
$ascii_value = ord("e");    # now 101
$character   = chr(101);    # now "e"
#-----------------------------
printf("Number %d is character %c\n", 101, 101);
#-----------------------------
@ascii_character_numbers = unpack("C*", "sample");
print "@ascii_character_numbers\n";
115 97 109 112 108 101


$word = pack("C*", @ascii_character_numbers);
$word = pack("C*", 115, 97, 109, 112, 108, 101);   # same
print "$word\n";
sample
#-----------------------------
$hal = "HAL";
@ascii = unpack("C*", $hal);
foreach $val (@ascii) {
    $val++;                 # add one to each ASCII value
}
$ibm = pack("C*", @ascii);
print "$ibm\n";             # prints "IBM"
#-----------------------------

# ^^PLEAC^^_1.5
#-----------------------------
@array = split(//, $string);

@array = unpack("C*", $string);
#-----------------------------
    while (/(.)/g) { # . is never a newline here
        # do something with $1
    }
#-----------------------------
%seen = ();
$string = "an apple a day";
foreach $byte (split //, $string) {
    $seen{$byte}++;
}
print "unique chars are: ", sort(keys %seen), "\n";
unique chars are:  adelnpy
#-----------------------------
%seen = ();
$string = "an apple a day";
while ($string =~ /(.)/g) {
    $seen{$1}++;
}
print "unique chars are: ", sort(keys %seen), "\n";
unique chars are:  adelnpy
#-----------------------------
$sum = 0;
foreach $ascval (unpack("C*", $string)) {
    $sum += $ascval;
}
print "sum is $sum\n";
# prints "1248" if $string was "an apple a day"
#-----------------------------
$sum = unpack("%32C*", $string);
#-----------------------------
# ^^INCLUDE^^ include/perl/ch01/sum
#-----------------------------
#% perl sum /etc/termcap
#1510
#-----------------------------
#% sum --sysv /etc/termcap
#1510 851 /etc/termcap
#-----------------------------
# ^^INCLUDE^^ include/perl/ch01/slowcat
#-----------------------------

# ^^PLEAC^^_1.6
#-----------------------------
$revbytes = reverse($string);
#-----------------------------
$revwords = join(" ", reverse split(" ", $string));
#-----------------------------
$gnirts   = reverse($string);       # reverse letters in $string

@sdrow    = reverse(@words);        # reverse elements in @words

$confused = reverse(@words);        # reverse letters in join("", @words)
#-----------------------------
# reverse word order
$string = 'Yoda said, "can you see this?"';
@allwords    = split(" ", $string);
$revwords    = join(" ", reverse @allwords);
print $revwords, "\n";
this?" see you "can said, Yoda
#-----------------------------
$revwords = join(" ", reverse split(" ", $string));
#-----------------------------
$revwords = join("", reverse split(/(\s+)/, $string));
#-----------------------------
$word = "reviver";
$is_palindrome = ($word eq reverse($word));
#-----------------------------
#% perl -nle 'print if $_ eq reverse && length > 5' /usr/dict/words
#deedeed
#
#degged
#
#deified
#
#denned
#
#hallah
#
#kakkak
#
#murdrum
#
#redder
#
#repaper
#
#retter
#
#reviver
#
#rotator
#
#sooloos
#
#tebbet
#
#terret
#
#tut-tut
#-----------------------------

# ^^PLEAC^^_1.7
#-----------------------------
while ($string =~ s/\t+/' ' x (length($&) * 8 - length($`) % 8)/e) {
    # spin in empty loop until substitution finally fails
}
#-----------------------------
use Text::Tabs;
@expanded_lines  = expand(@lines_with_tabs);
@tabulated_lines = unexpand(@lines_without_tabs);
#-----------------------------
while (<>) {
    1 while s/\t+/' ' x (length($&) * 8 - length($`) % 8)/e;
    print;
}
#-----------------------------
use Text::Tabs;
$tabstop = 4;
while (<>) { print expand($_) }
#-----------------------------
use Text::Tabs;
while (<>) { print unexpand($_) }
#-----------------------------

# ^^PLEAC^^_1.8
#-----------------------------
#You owe $debt to me.
#-----------------------------
$text =~ s/\$(\w+)/${$1}/g;
#-----------------------------
$text =~ s/(\$\w+)/$1/gee;
#-----------------------------
use vars qw($rows $cols);
no strict 'refs';                   # for ${$1}/g below
my $text;

($rows, $cols) = (24, 80);
$text = q(I am $rows high and $cols long);  # like single quotes!
$text =~ s/\$(\w+)/${$1}/g;
print $text;
I am 24 high and 80 long
#-----------------------------
$text = "I am 17 years old";
$text =~ s/(\d+)/2 * $1/eg; 
#-----------------------------
2 * 17
#-----------------------------
$text = 'I am $AGE years old';      # note single quotes
$text =~ s/(\$\w+)/$1/eg;           # WRONG
#-----------------------------
'$AGE'
#-----------------------------
$text =~ s/(\$\w+)/$1/eeg;          # finds my() variables
#-----------------------------
# expand variables in $text, but put an error message in
# if the variable isn't defined
$text =~ s{
     \$                         # find a literal dollar sign
    (\w+)                       # find a "word" and store it in $1
}{
    no strict 'refs';           # for $$1 below
    if (defined ${$1}) {
        ${$1};                  # expand global variables only
    } else {
        "[NO VARIABLE: \$$1]";  # error msg
    }
}egx;
#-----------------------------

# ^^PLEAC^^_1.9
#-----------------------------
use locale;                     # needed in 5.004 or above

$big = uc($little);             # "bo peep" -> "BO PEEP"
$little = lc($big);             # "JOHN"    -> "john"
$big = "\U$little";             # "bo peep" -> "BO PEEP"
$little = "\L$big";             # "JOHN"    -> "john"
#-----------------------------
$big = "\u$little";             # "bo"      -> "Bo"
$little = "\l$big";             # "BoPeep"    -> "boPeep" 
#-----------------------------
use locale;                     # needed in 5.004 or above

$beast   = "dromedary";
# capitalize various parts of $beast
$capit   = ucfirst($beast);         # Dromedary
$capit   = "\u\L$beast";            # (same)
$capall  = uc($beast);              # DROMEDARY
$capall  = "\U$beast";              # (same)
$caprest = lcfirst(uc($beast));     # dROMEDARY
$caprest = "\l\U$beast";            # (same)
#-----------------------------
# capitalize each word's first character, downcase the rest
$text = "thIS is a loNG liNE";
$text =~ s/(\w+)/\u\L$1/g;
print $text;
This Is A Long Line
#-----------------------------
if (uc($a) eq uc($b)) {
    print "a and b are the same\n";
}
#-----------------------------
# ^^INCLUDE^^ include/perl/ch01/randcap

#% randcap < genesis | head -9
#boOk 01 genesis
#
#
#001:001 in the BEginning goD created the heaven and tHe earTh.
#
#    
#
#001:002 and the earth wAS without ForM, aND void; AnD darkneSS was
#
#	 upon The Face of the dEEp. and the spIrit of GOd movEd upOn
#
#	 tHe face of the Waters.
#
#
#001:003 and god Said, let there be ligHt: and therE wAs LigHt.
#-----------------------------
sub randcase {
    rand(100) < 20 ? ("\040" ^ $_[0]) : $_[0];
}
#-----------------------------
$string &= "\177" x length($string);
#-----------------------------

# ^^PLEAC^^_1.10
#-----------------------------
$answer = $var1 . func() . $var2;   # scalar only
#-----------------------------
$answer = "STRING @{[ LIST EXPR ]} MORE STRING";
$answer = "STRING ${\( SCALAR EXPR )} MORE STRING";
#-----------------------------
$phrase = "I have " . ($n + 1) . " guanacos.";
$phrase = "I have ${\($n + 1)} guanacos.";
#-----------------------------
print "I have ",  $n + 1, " guanacos.\n";
#-----------------------------
some_func("What you want is @{[ split /:/, $rec ]} items");
#-----------------------------
die "Couldn't send mail" unless send_mail(<<"EOTEXT", $target);
To: $naughty
From: Your Bank
Cc: @{ get_manager_list($naughty) }
Date: @{[ do { my $now = `date`; chomp $now; $now } ]} (today)

Dear $naughty,

Today, you bounced check number @{[ 500 + int rand(100) ]} to us.
Your account is now closed.

Sincerely,
the management
EOTEXT
#-----------------------------

# ^^PLEAC^^_1.11
#-----------------------------
# all in one
($var = <<HERE_TARGET) =~ s/^\s+//gm;
    your text
    goes here
HERE_TARGET

# or with two steps
$var = <<HERE_TARGET;
    your text
    goes here
HERE_TARGET
$var =~ s/^\s+//gm;
#-----------------------------
($definition = <<'FINIS') =~ s/^\s+//gm;
    The five varieties of camelids
    are the familiar camel, his friends
    the llama and the alpaca, and the
    rather less well-known guanaco
    and vicuña.
FINIS
#-----------------------------
sub fix {
    my $string = shift;
    $string =~ s/^\s+//gm;
    return $string;
}

print fix(<<"END");
    My stuff goes here
END

# With function predeclaration, you can omit the parens:
print fix <<"END";
    My stuff goes here
END
#-----------------------------
($quote = <<'    FINIS') =~ s/^\s+//gm;
        ...we will have peace, when you and all your works have
        perished--and the works of your dark master to whom you would
        deliver us. You are a liar, Saruman, and a corrupter of mens
        hearts.  --Theoden in /usr/src/perl/taint.c
    FINIS
$quote =~ s/\s+--/\n--/;      #move attribution to line of its own
#-----------------------------
if ($REMEMBER_THE_MAIN) {
    $perl_main_C = dequote<<'    MAIN_INTERPRETER_LOOP';
        @@@ int
        @@@ runops() {
        @@@     SAVEI32(runlevel);
        @@@     runlevel++;
        @@@     while ( op = (*op->op_ppaddr)() ) ;
        @@@     TAINT_NOT;
        @@@     return 0;
        @@@ }
    MAIN_INTERPRETER_LOOP
    # add more code here if you want
}
#-----------------------------
sub dequote;
$poem = dequote<<EVER_ON_AND_ON;
       Now far ahead the Road has gone,
          And I must follow, if I can,
       Pursuing it with eager feet,
          Until it joins some larger way
       Where many paths and errands meet.
          And whither then? I cannot say.
                --Bilbo in /usr/src/perl/pp_ctl.c
EVER_ON_AND_ON
print "Here's your poem:\n\n$poem\n";
#-----------------------------
#Here's your poem:  
#
#Now far ahead the Road has gone,
#
#   And I must follow, if I can,
#
#Pursuing it with eager feet,
#
#   Until it joins some larger way
#
#Where many paths and errands meet.
#
#   And whither then? I cannot say.
#
#	  --Bilbo in /usr/src/perl/pp_ctl.c
#-----------------------------
sub dequote {
    local $_ = shift;
    my ($white, $leader);  # common whitespace and common leading string
    if (/^\s*(?:([^\w\s]+)(\s*).*\n)(?:\s*\1\2?.*\n)+$/) {
        ($white, $leader) = ($2, quotemeta($1));
    } else {
        ($white, $leader) = (/^(\s+)/, '');
    }
    s/^\s*?$leader(?:$white)?//gm;
    return $_;
}
#-----------------------------
    if (m{
            ^                       # start of line
            \s *                    # 0 or more whitespace chars
            (?:                     # begin first non-remembered grouping
                 (                  #   begin save buffer $1
                    [^\w\s]         #     one byte neither space nor word
                    +               #     1 or more of such
                 )                  #   end save buffer $1
                 ( \s* )            #   put 0 or more white in buffer $2
                 .* \n              #   match through the end of first line
             )                      # end of first grouping
             (?:                    # begin second non-remembered grouping
                \s *                #   0 or more whitespace chars
                \1                  #   whatever string is destined for $1
                \2 ?                #   what'll be in $2, but optionally
                .* \n               #   match through the end of the line
             ) +                    # now repeat that group idea 1 or more
             $                      # until the end of the line
          }x
       )
    {
        ($white, $leader) = ($2, quotemeta($1));
    } else {
        ($white, $leader) = (/^(\s+)/, '');
    }
    s{
         ^                          # start of each line (due to /m)
         \s *                       # any amount of leading whitespace
            ?                       #   but minimally matched
         $leader                    # our quoted, saved per-line leader
         (?:                        # begin unremembered grouping
            $white                  #    the same amount
         ) ?                        # optionalize in case EOL after leader
    }{}xgm;
#-----------------------------

# ^^PLEAC^^_1.12
#-----------------------------
use Text::Wrap;
@OUTPUT = wrap($LEADTAB, $NEXTTAB, @PARA);
#-----------------------------
# ^^INCLUDE^^ include/perl/ch01/wrapdemo
#-----------------------------
01234567890123456789

    Folding and

  splicing is the

  work of an

  editor, not a

  mere collection

  of silicon and

  mobile electrons!
#-----------------------------
# merge multiple lines into one, then wrap one long line
use Text::Wrap;
undef $/;
print wrap('', '', split(/\s*\n\s*/, <>));
#-----------------------------
use Text::Wrap      qw(&wrap $columns);
use Term::ReadKey   qw(GetTerminalSize);
($columns) = GetTerminalSize();
($/, $\)  = ('', "\n\n");   # read by paragraph, output 2 newlines
while (<>) {                # grab a full paragraph
    s/\s*\n\s*/ /g;         # convert intervening newlines to spaces
    print wrap('', '', $_); # and format
}
#-----------------------------

# ^^PLEAC^^_1.13
#-----------------------------
# backslash
$var =~ s/([CHARLIST])/\\$1/g;

# double
$var =~ s/([CHARLIST])/$1$1/g;
#-----------------------------
$string =~ s/%/%%/g;
#-----------------------------
$string = q(Mom said, "Don't do that."); #'
$string =~ s/(['"])/\\$1/g;
#-----------------------------
$string = q(Mom said, "Don't do that.");
$string =~ s/(['"])/$1$1/g;
#-----------------------------
$string =~ s/([^A-Z])/\\$1/g;
#-----------------------------
$string = "this \Qis a test!\E";
$string = "this is\\ a\\ test\\!";
$string = "this " . quotemeta("is a test!");
#-----------------------------

# ^^PLEAC^^_1.14
#-----------------------------
$string =~ s/^\s+//;
$string =~ s/\s+$//;
#-----------------------------
$string = trim($string);
@many   = trim(@many);

sub trim {
    my @out = @_;
    for (@out) {
        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @out : $out[0];
}
#-----------------------------
# print what's typed, but surrounded by >< symbols
while(<STDIN>) {
    chomp;
    print ">$_<\n";
}
#-----------------------------

# ^^PLEAC^^_1.15
#-----------------------------
sub parse_csv {
    my $text = shift;      # record containing comma-separated values
    my @new  = ();
    push(@new, $+) while $text =~ m{
        # the first part groups the phrase inside the quotes.
        # see explanation of this pattern in MRE
        "([^\"\\]*(?:\\.[^\"\\]*)*)",?
           |  ([^,]+),?
           | ,
       }gx;
       push(@new, undef) if substr($text, -1,1) eq ',';
       return @new;      # list of values that were comma-separated
}
#-----------------------------
use
Text::ParseWords;

sub parse_csv {
    return quoteword(",",0, $_[0]);
}
#-----------------------------
$line = q<XYZZY,"","O'Reilly, Inc","Wall, Larry","a \"glug\" bit,",5,
    "Error, Core Dumped">;
@fields = parse_csv($line);
for ($i = 0; $i < @fields; $i++) {
    print "$i : $fields[$i]\n";
}
#0 : XYZZY
#
#1 :
#
#2 : O'Reilly, Inc
#
#3 : Wall, Larry
#
#4 : a \"glug\" bit,
#
#5 : 5
#
#6 : Error, Core Dumped
#-----------------------------

# ^^PLEAC^^_1.16
#-----------------------------
 use Text::Soundex;

 $CODE  = soundex($STRING);
 @CODES = soundex(@LIST);
#-----------------------------
use Text::Soundex;
use User::pwent;

print "Lookup user: ";
chomp($user = <STDIN>);
exit unless defined $user;
$name_code = soundex($user);

while ($uent = getpwent()) {
    ($firstname, $lastname) = $uent->gecos =~ /(\w+)[^,]*\b(\w+)/;

    if ($name_code eq soundex($uent->name) ||
        $name_code eq soundex($lastname)   ||
        $name_code eq soundex($firstname)  )
    {
        printf "%s: %s %s\n", $uent->name, $firstname, $lastname;
    }
}
#-----------------------------

# ^^PLEAC^^_1.17
#-----------------------------
# ^^INCLUDE^^ include/perl/ch01/fixstyle
#analysed        => analyzed
#built-in        => builtin
#chastized       => chastised
#commandline     => command-line
#de-allocate     => deallocate
#dropin          => drop-in
#hardcode        => hard-code
#meta-data       => metadata
#multicharacter  => multi-character
#multiway        => multi-way
#non-empty       => nonempty
#non-profit      => nonprofit
#non-trappable   => nontrappable
#pre-define      => predefine
#preextend       => pre-extend
#re-compiling    => recompiling
#reenter         => re-enter
#turnkey         => turn-key
#-----------------------------
# ^^INCLUDE^^ include/perl/ch01/fixstyle2
#analysed        => analyzed
#built-in        => builtin
#chastized       => chastised
#commandline     => command-line
#de-allocate     => deallocate
#dropin          => drop-in
#hardcode        => hard-code
#meta-data       => metadata
#multicharacter  => multi-character
#multiway        => multi-way
#non-empty       => nonempty
#non-profit      => nonprofit
#non-trappable   => nontrappable
#pre-define      => predefine
#preextend       => pre-extend
#re-compiling    => recompiling
#reenter         => re-enter
#turnkey         => turn-key
#-----------------------------
# very fast, but whitespace collapse
while (<>) { 
    for (split) { 
        print $change{$_} || $_, " ";
    }
    print "\n";
}
#-----------------------------
my $pid = open(STDOUT, "|-");
die "cannot fork: $!" unless defined $pid;
unless ($pid) {             # child
        while (<STDIN>) {
        s/ $//;
        print;
    }
    exit;
}
#-----------------------------

# ^^PLEAC^^_1.18
#-----------------------------
#% psgrep '/sh\b/'
#-----------------------------
#% psgrep 'command =~ /sh$/'
#-----------------------------
#% psgrep 'uid < 10'
#-----------------------------
#% psgrep 'command =~ /^-/' 'tty ne "?"'
#-----------------------------
#% psgrep 'tty =~ /^[p-t]/'
#-----------------------------
#% psgrep 'uid && tty eq "?"'
#-----------------------------
#% psgrep 'size > 10 * 2**10' 'uid != 0'
#-----------------------------
# FLAGS   UID   PID  PPID PRI  NI   SIZE   RSS WCHAN     STA TTY TIME COMMAND
#
#     0   101  9751     1   0   0  14932  9652 do_select S   p1  0:25 netscape
#
#100000   101  9752  9751   0   0  10636   812 do_select S   p1  0:00 (dns helper)
#-----------------------------
# ^^INCLUDE^^ include/perl/ch01/psgrep
# the following was used to determine column cut points.
# sample input data follows
# 123456789012345678901234567890123456789012345678901234567890123456789012345
#          1         2         3         4         5         6         7
#  Positioning:
#        8     14    20    26  30  34     41    47          59  63  67   72
#        |     |     |     |   |   |      |     |           |   |   |    |
# __END__
#  FLAGS   UID   PID  PPID PRI  NI   SIZE   RSS WCHAN       STA TTY TIME COMMAND
# 
#    100     0     1     0   0   0    760   432 do_select   S   ?   0:02 init
# 
#    140     0   187     1   0   0    784   452 do_select   S   ?   0:02 syslogd
# 
# 100100   101   428     1   0   0   1436   944 do_exit     S    1  0:00 /bin/login
# 
# 100140    99 30217   402   0   0   1552  1008 posix_lock_ S   ?   0:00 httpd
# 
#      0   101   593   428   0   0   1780  1260 copy_thread S    1  0:00 -tcsh
# 
# 100000   101 30639  9562  17   0    924   496             R   p1  0:00 ps axl
# 
#      0   101 25145  9563   0   0   2964  2360 idetape_rea S   p2  0:06 trn
# 
# 100100     0 10116  9564   0   0   1412   928 setup_frame T   p3  0:00 ssh -C www
# 
# 100100     0 26560 26554   0   0   1076   572 setup_frame T   p2  0:00 less
# 
# 100000   101 19058  9562   0   0   1396   900 setup_frame T   p1  0:02 nvi /tmp/a
#-----------------------------
eval "sub is_desirable { uid < 10 } " . 1;
#-----------------------------
#% psgrep 'no strict "vars";
#          BEGIN { $id = getpwnam("nobody") }
#          uid == $id '
#-----------------------------
sub id()         { $_->{ID}   }
sub title()      { $_->{TITLE} }
sub executive()  { title =~ /(?:vice-)?president/i }

# user search criteria go in the grep clause
@slowburners = grep { id < 10 && !executive } @employees;
#-----------------------------

# ^^PLEAC^^_2.1
#-----------------------------
if ($string =~ /PATTERN/) {
    # is a number
} else {
    # is not
}
#-----------------------------
warn "has nondigits"        if     /\D/;
warn "not a natural number" unless /^\d+$/;             # rejects -3
warn "not an integer"       unless /^-?\d+$/;           # rejects +3
warn "not an integer"       unless /^[+-]?\d+$/;
warn "not a decimal number" unless /^-?\d+\.?\d*$/;     # rejects .2
warn "not a decimal number" unless /^-?(?:\d+(?:\.\d*)?|\.\d+)$/;
warn "not a C float"
       unless /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/;
#-----------------------------
sub getnum {
    use POSIX qw(strtod);
    my $str = shift;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    $! = 0;
    my($num, $unparsed) = strtod($str);
    if (($str eq '') || ($unparsed != 0) || $!) {
        return;
    } else {
        return $num;
    } 
} 

sub is_numeric { defined scalar &getnum } 
#-----------------------------

# ^^PLEAC^^_2.2
#-----------------------------
# equal(NUM1, NUM2, ACCURACY) : returns true if NUM1 and NUM2 are
# equal to ACCURACY number of decimal places

sub equal {
    my ($A, $B, $dp) = @_;

    return sprintf("%.${dp}g", $A) eq sprintf("%.${dp}g", $B);
  }
#-----------------------------
$wage = 536;                # $5.36/hour
$week = 40 * $wage;         # $214.40
printf("One week's wage is: \$%.2f\n", $week/100);
#
#One week's wage is: $214.40
#-----------------------------

# ^^PLEAC^^_2.3
#-----------------------------
$rounded = sprintf("%FORMATf", $unrounded);
#-----------------------------
$a = 0.255;
$b = sprintf("%.2f", $a);
print "Unrounded: $a\nRounded: $b\n";
printf "Unrounded: $a\nRounded: %.2f\n", $a;

# Unrounded: 0.255
# 
# Rounded: 0.26
# 
# Unrounded: 0.255
# 
# Rounded: 0.26
#-----------------------------
use POSIX;
print "number\tint\tfloor\tceil\n";
@a = ( 3.3 , 3.5 , 3.7, -3.3 );
foreach (@a) {
    printf( "%.1f\t%.1f\t%.1f\t%.1f\n", 
        $_, int($_), floor($_), ceil($_) );
}

# number  int     floor   ceil
# 
#  3.3     3.0     3.0     4.0
# 
#  3.5     3.0     3.0     4.0
# 
#  3.7     3.0     3.0     4.0
# 
# -3.3    -3.0    -4.0    -3.0
#-----------------------------

# ^^PLEAC^^_2.4
#-----------------------------
sub dec2bin {
    my $str = unpack("B32", pack("N", shift));
    $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
    return $str;
}
#-----------------------------
sub bin2dec {
    return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}
#-----------------------------
$num = bin2dec('0110110');  # $num is 54
$binstr = dec2bin(54);      # $binstr is 110110
#-----------------------------

# ^^PLEAC^^_2.5
#-----------------------------
foreach ($X .. $Y) {
    # $_ is set to every integer from X to Y, inclusive
}

foreach $i ($X .. $Y) {
    # $i is set to every integer from X to Y, inclusive
    }

for ($i = $X; $i <= $Y; $i++) {
    # $i is set to every integer from X to Y, inclusive
}

for ($i = $X; $i <= $Y; $i += 7) {
    # $i is set to every integer from X to Y, stepsize = 7
}
#-----------------------------
print "Infancy is: ";
foreach (0 .. 2) {
    print "$_ ";
}
print "\n";

print "Toddling is: ";
foreach $i (3 .. 4) {
    print "$i ";
}
print "\n";

print "Childhood is: ";
for ($i = 5; $i <= 12; $i++) {
    print "$i ";
}
print "\n";

# Infancy is: 0 1 2 
# 
# Toddling is: 3 4 
# 
# Childhood is: 5 6 7 8 9 10 11 12 
#-----------------------------

# ^^PLEAC^^_2.6
#-----------------------------
use Roman;
$roman = roman($arabic);                        # convert to roman numerals
$arabic = arabic($roman) if isroman($roman);    # convert from roman numerals
#-----------------------------
use Roman;
$roman_fifteen = roman(15);                         # "xv"
print "Roman for fifteen is $roman_fifteen\n";
$arabic_fifteen = arabic($roman_fifteen);
print "Converted back, $roman_fifteen is $arabic_fifteen\n";

Roman for fifteen is xv

Converted back, xv is 15
#-----------------------------

# ^^PLEAC^^_2.7
#-----------------------------
$random = int( rand( $Y-$X+1 ) ) + $X;
#-----------------------------
$random = int( rand(51)) + 25;
print "$random\n";
#-----------------------------
$elt = $array[ rand @array ];
#-----------------------------
@chars = ( "A" .. "Z", "a" .. "z", 0 .. 9, qw(! @ $ % ^ & *) );
$password = join("", @chars[ map { rand @chars } ( 1 .. 8 ) ]);
#-----------------------------

# ^^PLEAC^^_2.8
#-----------------------------
srand EXPR;
#-----------------------------
srand( <STDIN> );
#-----------------------------

# ^^PLEAC^^_2.9
#-----------------------------
use Math::TrulyRandom;
$random = truly_random_value();

use Math::Random;
$random = random_uniform();
#-----------------------------

# ^^PLEAC^^_2.10
#-----------------------------
sub gaussian_rand {
    my ($u1, $u2);  # uniformly distributed random numbers
    my $w;          # variance, then a weight
    my ($g1, $g2);  # gaussian-distributed numbers

    do {
        $u1 = 2 * rand() - 1;
        $u2 = 2 * rand() - 1;
        $w = $u1*$u1 + $u2*$u2;
    } while ( $w >= 1 );

    $w = sqrt( (-2 * log($w))  / $w );
    $g2 = $u1 * $w;
    $g1 = $u2 * $w;
    # return both if wanted, else just one
    return wantarray ? ($g1, $g2) : $g1;
}
#-----------------------------
# weight_to_dist: takes a hash mapping key to weight and returns
# a hash mapping key to probability
sub weight_to_dist {
    my %weights = @_;
    my %dist    = ();
    my $total   = 0;
    my ($key, $weight);
    local $_;

    foreach (values %weights) {
        $total += $_;
    }

    while ( ($key, $weight) = each %weights ) {
        $dist{$key} = $weight/$total;
    }

    return %dist;
}

# weighted_rand: takes a hash mapping key to probability, and
# returns the corresponding element
sub weighted_rand {
    my %dist = @_;
    my ($key, $weight);

    while (1) {                     # to avoid floating point inaccuracies
        my $rand = rand;
        while ( ($key, $weight) = each %dist ) {
            return $key if ($rand -= $weight) < 0;
        }
    }
}
#-----------------------------
# gaussian_rand as above
$mean = 25;
$sdev = 2;
$salary = gaussian_rand() * $sdev + $mean;
printf("You have been hired at \$%.2f\n", $salary);
#-----------------------------

# ^^PLEAC^^_2.11
#-----------------------------
BEGIN {
    use constant PI => 3.14159265358979;

    sub deg2rad {
        my $degrees = shift;
        return ($degrees / 180) * PI;
    }

    sub rad2deg {
        my $radians = shift;
        return ($radians / PI) * 180;
    }
}
#-----------------------------
use Math::Trig;

$radians = deg2rad($degrees);
$degrees = rad2deg($radians);
#-----------------------------
# deg2rad and rad2deg defined either as above or from Math::Trig
sub degree_sine {
    my $degrees = shift;
    my $radians = deg2rad($degrees);
    my $result = sin($radians);

    return $result;
}
#-----------------------------

# ^^PLEAC^^_2.12
#-----------------------------
sub tan {
    my $theta = shift;

    return sin($theta)/cos($theta);
}
#-----------------------------
use POSIX;

$y = acos(3.7);
#-----------------------------
use Math::Trig;

$y = acos(3.7);
#-----------------------------
eval {
    $y = tan($pi/2);
} or return undef;
#-----------------------------

# ^^PLEAC^^_2.13
#-----------------------------
$log_e = log(VALUE);
#-----------------------------
use POSIX qw(log10);
$log_10 = log10(VALUE);
#-----------------------------
sub log_base {
    my ($base, $value) = @_;
    return log($value)/log($base);
}
#-----------------------------
# log_base defined as above
$answer = log_base(10, 10_000);
print "log10(10,000) = $answer\n";
# log10(10,000) = 4
#-----------------------------
use Math::Complex;
printf "log2(1024) = %lf\n", logn(1024, 2); # watch out for argument order!
# log2(1024) = 10.000000
#-----------------------------

# ^^PLEAC^^_2.14
#-----------------------------
use PDL;
# $a and $b are both pdl objects
$c = $a * $b;
#-----------------------------
sub mmult {
    my ($m1,$m2) = @_;
    my ($m1rows,$m1cols) = matdim($m1);
    my ($m2rows,$m2cols) = matdim($m2);

    unless ($m1cols == $m2rows) {  # raise exception
        die "IndexError: matrices don't match: $m1cols != $m2rows";
    }

    my $result = [];
    my ($i, $j, $k);

    for $i (range($m1rows)) {
        for $j (range($m2cols)) {
            for $k (range($m1cols)) {
                $result->[$i][$j] += $m1->[$i][$k] * $m2->[$k][$j];
            }
        }
    }
    return $result;
}

sub range { 0 .. ($_[0] - 1) }

sub veclen {
    my $ary_ref = $_[0];
    my $type = ref $ary_ref;
    if ($type ne "ARRAY") { die "$type is bad array ref for $ary_ref" }
    return scalar(@$ary_ref);
}

sub matdim {
    my $matrix = $_[0];
    my $rows = veclen($matrix);
    my $cols = veclen($matrix->[0]);
    return ($rows, $cols);
}
#-----------------------------
use PDL;

$a = pdl [
    [ 3, 2, 3 ],
    [ 5, 9, 8 ],
];

$b = pdl [
    [ 4, 7 ],
    [ 9, 3 ],
    [ 8, 1 ],
];

$c = $a x $b;  # x overload
#-----------------------------
# mmult() and other subroutines as above

$x = [
       [ 3, 2, 3 ],
       [ 5, 9, 8 ],
];

$y = [
       [ 4, 7 ],
       [ 9, 3 ],
       [ 8, 1 ],
];

$z = mmult($x, $y);
#-----------------------------

# ^^PLEAC^^_2.15
#-----------------------------
# $c = $a * $b manually
$c_real = ( $a_real * $b_real ) - ( $a_imaginary * $b_imaginary );
$c_imaginary = ( $a_real * $b_imaginary ) + ( $b_real * $a_imaginary );
#-----------------------------
# $c = $a * $b using Math::Complex
use Math::Complex;
$c = $a * $b;
#-----------------------------
$a_real = 3; $a_imaginary = 5;              # 3 + 5i;
$b_real = 2; $b_imaginary = -2;             # 2 - 2i;
$c_real = ( $a_real * $b_real ) - ( $a_imaginary * $b_imaginary );
$c_imaginary = ( $a_real * $b_imaginary ) + ( $b_real * $a_imaginary );
print "c = ${c_real}+${c_imaginary}i\n";

c = 16+4i
#-----------------------------
use Math::Complex;
$a = Math::Complex->new(3,5);               # or Math::Complex->new(3,5);
$b = Math::Complex->new(2,-2);
$c = $a * $b;
print "c = $c\n";

c = 16+4i
#-----------------------------
use Math::Complex;
$c = cplx(3,5) * cplx(2,-2);                # easier on the eye
$d = 3 + 4*i;                               # 3 + 4i
printf "sqrt($d) = %s\n", sqrt($d);

# sqrt(3+4i) = 2+i
#-----------------------------

# ^^PLEAC^^_2.16
#-----------------------------
$number = hex($hexadecimal);         # hexadecimal
$number = oct($octal);               # octal
#-----------------------------
print "Gimme a number in decimal, octal, or hex: ";
$num = <STDIN>;
chomp $num;
exit unless defined $num;
$num = oct($num) if $num =~ /^0/; # does both oct and hex
printf "%d %x %o\n", $num, $num, $num;
#-----------------------------
print "Enter file permission in octal: ";
$permissions = <STDIN>;
die "Exiting ...\n" unless defined $permissions;
chomp $permissions;
$permissions = oct($permissions);   # permissions always octal
print "The decimal value is $permissions\n";
#-----------------------------

# ^^PLEAC^^_2.17
#-----------------------------
sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}
#-----------------------------
# more reasonable web counter :-)
use Math::TrulyRandom;
$hits = truly_random_value();       # negative hits!
$output = "Your web page received $hits accesses last month.\n";
print commify($output);
Your web page received -1,740,525,205 accesses last month.
#-----------------------------

# ^^PLEAC^^_2.18
#-----------------------------
printf "It took %d hour%s\n", $time, $time == 1 ? "" : "s";

printf "%d hour%s %s enough.\n", $time, 
        $time == 1 ? ""   : "s",
        $time == 1 ? "is" : "are";
#-----------------------------
printf "It took %d centur%s", $time, $time == 1 ? "y" : "ies";
#-----------------------------
sub noun_plural {
    local $_ = shift;
    # order really matters here!
    s/ss$/sses/                             ||
    s/([psc]h)$/${1}es/                     ||
    s/z$/zes/                               ||
    s/ff$/ffs/                              ||
    s/f$/ves/                               ||
    s/ey$/eys/                              ||
    s/y$/ies/                               ||
    s/ix$/ices/                             ||
    s/([sx])$/$1es/                         ||
    s/$/s/                                  ||
                die "can't get here";
    return $_;
}
*verb_singular = \&noun_plural;   # make function alias
#-----------------------------
use Lingua::EN::Inflect qw(PL classical);
classical(1);               # why isn't this the default?
while (<DATA>) {            # each line in the data
    for (split) {           # each word on the line
        print "One $_, two ", PL($_), ".\n";
    }
} 
# plus one more
$_ = 'secretary general';
print "One $_, two ", PL($_), ".\n";

#__END__
#fish fly ox 
#species genus phylum 
#cherub radius jockey 
#index matrix mythos
#phenomenon formula 
#-----------------------------
#One fish, two fish.
#
#One fly, two flies.
#
#One ox, two oxen.
#
#One species, two species.
#
#One genus, two genera.
#
#One phylum, two phyla.
#
#One cherub, two cherubim.
#
#One radius, two radii.
#
#One jockey, two jockeys.
#
#One index, two indices.
#
#One matrix, two matrices.
#
#One mythos, two mythoi.
#
#One phenomenon, two phenomena.
#
#One formula, two formulae.
#
#One secretary general, two secretaries general.
#-----------------------------

# ^^PLEAC^^_2.19
#-----------------------------
#% bigfact 8 9 96 2178
#8          2**3
#
#9          3**2
#
#96         2**5 3
#
#2178       2 3**2 11**2
#-----------------------------
#% bigfact 239322000000000000000000
#+239322000000000000000000 2**19 3 5**18 +39887 
#
#
#% bigfact 25000000000000000000000000
#+25000000000000000000000000 2**24 5**26
#-----------------------------
# ^^INCLUDE^^ include/perl/ch02/bigfact
#-----------------------------

# ^^PLEAC^^_3.0
#-----------------------------
$sec
#-----------------------------
$min
#-----------------------------
$hours
#-----------------------------
$mday
#-----------------------------
$month
#-----------------------------
$year
#-----------------------------
$wday
#-----------------------------
$yday
#-----------------------------
$isdst
#-----------------------------
#Fri Apr 11 09:27:08 1997
#-----------------------------
# using arrays
print "Today is day ", (localtime)[7], " of the current year.\n";
# Today is day 117 of the current year.

# using Time::tm objects
use Time::localtime;
$tm = localtime;
print "Today is day ", $tm->yday, " of the current year.\n";
# Today is day 117 of the current year.
#-----------------------------

# ^^PLEAC^^_3.1
#-----------------------------
($DAY, $MONTH, $YEAR) = (localtime)[3,4,5];
#-----------------------------
use Time::localtime;
$tm = localtime;
($DAY, $MONTH, $YEAR) = ($tm->mday, $tm->mon, $tm->year);
#-----------------------------
($day, $month, $year) = (localtime)[3,4,5];
printf("The current date is %04d %02d %02d\n", $year+1900, $month+1, $day);
# The current date is 1998 04 28
#-----------------------------
($day, $month, $year) = (localtime)[3..5];
#-----------------------------
use Time::localtime;
$tm = localtime;
printf("The current date is %04d-%02d-%02d\n", $tm->year+1900, 
    ($tm->mon)+1, $tm->mday);
# The current date is 1998-04-28
#-----------------------------
printf("The current date is %04d-%02d-%02d\n",
       sub {($_[5]+1900, $_[4]+1, $_[3])}->(localtime));
#-----------------------------
use POSIX qw(strftime);
print strftime "%Y-%m-%d\n", localtime;
#-----------------------------

# ^^PLEAC^^_3.2
#-----------------------------
use Time::Local;
$TIME = timelocal($sec, $min, $hours, $mday, $mon, $year);
$TIME = timegm($sec, $min, $hours, $mday, $mon, $year);
#-----------------------------
# $hours, $minutes, and $seconds represent a time today,
# in the current time zone
use Time::Local;
$time = timelocal($seconds, $minutes, $hours, (localtime)[3,4,5]);
#-----------------------------
# $day is day in month (1-31)
# $month is month in year (1-12)
# $year is four-digit year e.g., 1967
# $hours, $minutes and $seconds represent UTC time 
use Time::Local;
$time = timegm($seconds, $minutes, $hours, $day, $month-1, $year-1900);
#-----------------------------

# ^^PLEAC^^_3.3
#-----------------------------
($seconds, $minutes, $hours, $day_of_month, $month, $year,
    $wday, $yday, $isdst) = localtime($time);
#-----------------------------
use Time::localtime;        # or Time::gmtime
$tm = localtime($TIME);     # or gmtime($TIME)
$seconds = $tm->sec;
# ...
#-----------------------------
($seconds, $minutes, $hours, $day_of_month, $month, $year,
    $wday, $yday, $isdst) = localtime($time);
printf("Dateline: %02d:%02d:%02d-%04d/%02d/%02d\n",
    $hours, $minutes, $seconds, $year+1900, $month+1,
    $day_of_month);
#-----------------------------
use Time::localtime;
$tm = localtime($time);
printf("Dateline: %02d:%02d:%02d-%04d/%02d/%02d\n",
    $tm->hour, $tm->min, $tm->sec, $tm->year+1900,
    $tm->mon+1, $tm->mday);
#-----------------------------

# ^^PLEAC^^_3.4
#-----------------------------
$when = $now + $difference;
$then = $now - $difference;
#-----------------------------
use Date::Calc qw(Add_Delta_Days);
($y2, $m2, $d2) = Add_Delta_Days($y, $m, $d, $offset);
#-----------------------------
use Date::Calc qw(Add_Delta_DHMS);
($year2, $month2, $day2, $h2, $m2, $s2) = 
    Add_Delta_DHMS( $year, $month, $day, $hour, $minute, $second,
                $days_offset, $hour_offset, $minute_offset, $second_offset );
#-----------------------------
$birthtime = 96176750;                  # 18/Jan/1973, 3:45:50 am
$interval = 5 +                         # 5 seconds
            17 * 60 +                   # 17 minutes
            2  * 60 * 60 +              # 2 hours
            55 * 60 * 60 * 24;          # and 55 days
$then = $birthtime + $interval;
print "Then is ", scalar(localtime($then)), "\n";
# Then is Wed Mar 14 06:02:55 1973
#-----------------------------
use Date::Calc qw(Add_Delta_DHMS);
($year, $month, $day, $hh, $mm, $ss) = Add_Delta_DHMS(
    1973, 1, 18, 3, 45, 50, # 18/Jan/1973, 3:45:50 am
             55, 2, 17, 5); # 55 days, 2 hrs, 17 min, 5 sec
print "To be precise: $hh:$mm:$ss, $month/$day/$year\n";
# To be precise: 6:2:55, 3/14/1973
#-----------------------------
use Date::Calc qw(Add_Delta_Days);
($year, $month, $day) = Add_Delta_Days(1973, 1, 18, 55);
print "Nat was 55 days old on: $month/$day/$year\n";
# Nat was 55 days old on: 3/14/1973
#-----------------------------

# ^^PLEAC^^_3.5
#-----------------------------
$seconds = $recent - $earlier;
#-----------------------------
use Date::Calc qw(Delta_Days);
$days = Delta_Days( $year1, $month1, $day1, $year2, $month2, $day2);
#-----------------------------
use Date::Calc qw(Delta_DHMS);
($days, $hours, $minutes, $seconds) =
  Delta_DHMS( $year1, $month1, $day1, $hour1, $minute1, $seconds1,  # earlier
              $year2, $month2, $day2, $hour2, $minute2, $seconds2); # later
#-----------------------------
$bree = 361535725;          # 16 Jun 1981, 4:35:25
$nat  =  96201950;          # 18 Jan 1973, 3:45:50

$difference = $bree - $nat;
print "There were $difference seconds between Nat and Bree\n";
# There were 265333775 seconds between Nat and Bree


$seconds    =  $difference % 60;
$difference = ($difference - $seconds) / 60;
$minutes    =  $difference % 60;
$difference = ($difference - $minutes) / 60;
$hours      =  $difference % 24;
$difference = ($difference - $hours)   / 24;
$days       =  $difference % 7;
$weeks      = ($difference - $days)    /  7;

print "($weeks weeks, $days days, $hours:$minutes:$seconds)\n";
# (438 weeks, 4 days, 23:49:35)
#-----------------------------
use Date::Calc qw(Delta_Days);
@bree = (1981, 6, 16);      # 16 Jun 1981
@nat  = (1973, 1, 18);      # 18 Jan 1973
$difference = Delta_Days(@nat, @bree);
print "There were $difference days between Nat and Bree\n";
# There were 3071 days between Nat and Bree
#-----------------------------
use Date::Calc qw(Delta_DHMS);
@bree = (1981, 6, 16, 4, 35, 25);   # 16 Jun 1981, 4:35:25
@nat  = (1973, 1, 18, 3, 45, 50);   # 18 Jan 1973, 3:45:50
@diff = Delta_DHMS(@nat, @bree);
print "Bree came $diff[0] days, $diff[1]:$diff[2]:$diff[3] after Nat\n";
# Bree came 3071 days, 0:49:35 after Nat
#-----------------------------

# ^^PLEAC^^_3.6
#-----------------------------
($MONTHDAY, $WEEKDAY, $YEARDAY) = (localtime $DATE)[3,6,7];
$WEEKNUM = int($YEARDAY / 7) + 1;
#-----------------------------
use Date::Calc qw(Day_of_Week Week_Number Day_of_Year);
# you have $year, $month, and $day
# $day is day of month, by definition.
$wday = Day_of_Week($year, $month, $day);
$wnum = Week_Number($year, $month, $day);
$dnum = Day_of_Year($year, $month, $day);
#-----------------------------
use Date::Calc qw(Day_of_Week Week_Number Day_of_Week_to_Text)

$year  = 1981;
$month = 6;         # (June)
$day   = 16;

$wday = Day_of_Week($year, $month, $day);
print "$month/$day/$year was a ", Day_of_Week_to_Text($wday), "\n";
## see comment above

$wnum = Week_Number($year, $month, $day);
print "in the $wnum week.\n";
# 6/16/1981 was a Tuesday
# 
# in week number 25.
#-----------------------------

# ^^PLEAC^^_3.7
#-----------------------------
use Time::Local;
# $date is "1998-06-03" (YYYY-MM-DD form).
($yyyy, $mm, $dd) = $date =~ /(\d+)-(\d+)-(\d+)/;
# calculate epoch seconds at midnight on that day in this timezone
$epoch_seconds = timelocal(0, 0, 0, $dd, $mm, $yyyy);
#-----------------------------
use Date::Manip qw(ParseDate UnixDate);
$date = ParseDate($string);
if (!$date) {
    # bad date
} else {
    @values = UnixDate($date, @formats);
}
#-----------------------------
use Date::Manip qw(ParseDate UnixDate);

while (<>) {
    $date = ParseDate($_);
    if (!$date) {
        warn "Bad date string: $_\n";
        next;
    } else {
        ($year, $month, $day) = UnixDate($date, "%Y", "%m", "%d");
        print "Date was $month/$day/$year\n";
    }
}
#-----------------------------

# ^^PLEAC^^_3.8
#-----------------------------
$STRING = localtime($EPOCH_SECONDS);
#-----------------------------
use POSIX qw(strftime);
$STRING = strftime($FORMAT, $SECONDS, $MINUTES, $HOUR,
                   $DAY_OF_MONTH, $MONTH, $YEAR, $WEEKDAY,
                   $YEARDAY, $DST);
#-----------------------------
use Date::Manip qw(UnixDate);
$STRING = UnixDate($DATE, $FORMAT);
#-----------------------------
# Sun Sep 21 15:33:36 1997
#-----------------------------
use Time::Local;
$time = timelocal(50, 45, 3, 18, 0, 73);
print "Scalar localtime gives: ", scalar(localtime($time)), "\n";
# Scalar localtime gives: Thu Jan 18 03:45:50 1973
#-----------------------------
use POSIX qw(strftime);
use Time::Local;
$time = timelocal(50, 45, 3, 18, 0, 73);
print "strftime gives: ", strftime("%A %D", localtime($time)), "\n";
# strftime gives: Thursday 01/18/73
#-----------------------------
use Date::Manip qw(ParseDate UnixDate);
$date = ParseDate("18 Jan 1973, 3:45:50");
$datestr = UnixDate($date, "%a %b %e %H:%M:%S %z %Y");    # as scalar
print "Date::Manip gives: $datestr\n";
# Date::Manip gives: Thu Jan 18 03:45:50 GMT 1973
#-----------------------------

# ^^PLEAC^^_3.9
#-----------------------------
use Time::HiRes qw(gettimeofday);
$t0 = gettimeofday;
## do your operation here
$t1 = gettimeofday;
$elapsed = $t1 - $t0;
# $elapsed is a floating point value, representing number
# of seconds between $t0 and $t1
#-----------------------------
use Time::HiRes qw(gettimeofday);
print "Press return when ready: ";
$before = gettimeofday;
$line = <>;
$elapsed = gettimeofday-$before;
print "You took $elapsed seconds.\n";
# Press return when ready: 
# 
# You took 0.228149 seconds.
#-----------------------------
require 'sys/syscall.ph';

# initialize the structures returned by gettimeofday
$TIMEVAL_T = "LL";
$done = $start = pack($TIMEVAL_T, ());

# prompt
print "Press return when ready: ";

# read the time into $start
syscall(&SYS_gettimeofday, $start, 0) != -1
           || die "gettimeofday: $!";

# read a line
$line = <>;

# read the time into $done
syscall(&SYS_gettimeofday, $done, 0) != -1
       || die "gettimeofday: $!";

# expand the structure
@start = unpack($TIMEVAL_T, $start);
@done  = unpack($TIMEVAL_T, $done);

# fix microseconds
for ($done[1], $start[1]) { $_ /= 1_000_000 }
    
# calculate time difference
$delta_time = sprintf "%.4f", ($done[0]  + $done[1]  )
                                         -
                              ($start[0] + $start[1] );

print "That took $delta_time seconds\n";
# Press return when ready: 
# 
# That took 0.3037 seconds
#-----------------------------
use Time::HiRes qw(gettimeofday);
# take mean sorting time
$size = 500;
$number_of_times = 100;
$total_time = 0;

for ($i = 0; $i < $number_of_times; $i++) {
    my (@array, $j, $begin, $time);
    # populate array
    @array = ();
    for ($j=0; $j<$size; $j++) { push(@array, rand) }

    # sort it
    $begin = gettimeofday;
    @array = sort { $a <=> $b } @array;
    $time = gettimeofday-$begin;
    $total_time += $time;
}

printf "On average, sorting %d random numbers takes %.5f seconds\n",
    $size, ($total_time/$number_of_times);
# On average, sorting 500 random numbers takes 0.02821 seconds
#-----------------------------

# ^^PLEAC^^_3.10
#-----------------------------
select(undef, undef, undef, $time_to_sleep);
#-----------------------------
use Time::HiRes qw(sleep);
sleep($time_to_sleep);
#-----------------------------
while (<>) {
    select(undef, undef, undef, 0.25);
    print;
}
#-----------------------------
use Time::HiRes qw(sleep);
while (<>) {
    sleep(0.25);
    print;
}
#-----------------------------

# ^^PLEAC^^_3.11
#-----------------------------
use Date::Manip qw(ParseDate DateCalc);
$d1 = ParseDate("Tue, 26 May 1998 23:57:38 -0400");
$d2 = ParseDate("Wed, 27 May 1998 05:04:03 +0100");
print DateCalc($d1, $d2);
# +0:0:0:0:0:6:25
#-----------------------------
# ^^INCLUDE^^ include/perl/ch03/hopdelta
#-----------------------------
# Sender               Recipient            Time                   Delta
# 
# Start                wall.org             09:17:12 1998/05/23
# 
# wall.org             mail.brainstorm.net  09:20:56 1998/05/23    44s   3m
# 
# mail.brainstorm.net  jhereg.perl.com      09:20:58 1998/05/23     2s
#  
#-----------------------------

# ^^PLEAC^^_4.0
#-----------------------------
@nested = ("this", "that", "the", "other");
@nested = ("this", "that", ("the", "other"));
#-----------------------------
@tune = ( "The", "Star-Spangled", "Banner" );
#-----------------------------

# ^^PLEAC^^_4.1
#-----------------------------
@a = ("quick", "brown", "fox");
#-----------------------------
@a = qw(Why are you teasing me?);
#-----------------------------
@lines = (<<"END_OF_HERE_DOC" =~ m/^\s*(.+)/gm);
    The boy stood on the burning deck,
    It was as hot as glass.
END_OF_HERE_DOC
#-----------------------------
@bigarray = ();
open(DATA, "< mydatafile")       or die "Couldn't read from datafile: $!\n";
while (<DATA>) {
    chomp;
    push(@bigarray, $_);
}
#-----------------------------
$banner = 'The Mines of Moria';
$banner = q(The Mines of Moria);
#-----------------------------
$name   =  "Gandalf";
$banner = "Speak, $name, and enter!";
$banner = qq(Speak, $name, and welcome!);
#-----------------------------
$his_host   = 'www.perl.com';
$host_info  = `nslookup $his_host`; # expand Perl variable

$perl_info  = qx(ps $$);            # that's Perl's $$
$shell_info = qx'ps $$';            # that's the new shell's $$
#-----------------------------
@banner = ('Costs', 'only', '$4.95');
@banner = qw(Costs only $4.95);
@banner = split(' ', 'Costs only $4.95');
#-----------------------------
@brax   = qw! ( ) < > { } [ ] !;
@rings  = qw(Nenya Narya Vilya);
@tags   = qw<LI TABLE TR TD A IMG H1 P>;
@sample = qw(The vertical bar (|) looks and behaves like a pipe.);
#-----------------------------
@banner = qw|The vertical bar (\|) looks and behaves like a pipe.|;
#-----------------------------
@ships  = qw(Niña Pinta Santa María);               # WRONG
@ships  = ('Niña', 'Pinta', 'Santa María');         # right
#-----------------------------

# ^^PLEAC^^_4.2
#-----------------------------
sub commify_series {
    (@_ == 0) ? ''                                      :
    (@_ == 1) ? $_[0]                                   :
    (@_ == 2) ? join(" and ", @_)                       :
                join(", ", @_[0 .. ($#_-1)], "and $_[-1]");
}
#-----------------------------
@array = ("red", "yellow", "green");
print "I have ", @array, " marbles.\n";
print "I have @array marbles.\n";
I have redyellowgreen marbles.

I have red yellow green marbles.
#-----------------------------
# ^^INCLUDE^^ include/perl/ch04/commify_series
#-----------------------------
#The list is: just one thing.
#
#The list is: Mutt and Jeff.
#
#The list is: Peter, Paul, and Mary.
#
#The list is: To our parents, Mother Theresa, and God.
#
#The list is: pastrami, ham and cheese, peanut butter and jelly, and tuna.
#
#The list is: recycle tired, old phrases and ponder big, happy thoughts.
#
#The list is: recycle tired, old phrases; ponder 
#
#   big, happy thoughts; and sleep and dream peacefully.
#-----------------------------

# ^^PLEAC^^_4.3
#-----------------------------
# grow or shrink @ARRAY
$#ARRAY = $NEW_LAST_ELEMENT_INDEX_NUMBER;
#-----------------------------
$ARRAY[$NEW_LAST_ELEMENT_INDEX_NUMBER] = $VALUE;
#-----------------------------
sub what_about_that_array {
    print "The array now has ", scalar(@people), " elements.\n";
    print "The index of the last element is $#people.\n";
    print "Element #3 is `$people[3]'.\n";
}

@people = qw(Crosby Stills Nash Young);
what_about_that_array();
#-----------------------------
The array now has 4 elements.

The index of the last element is 3.

Element #3 is `Young'.
#-----------------------------
$#people--;
what_about_that_array();
#-----------------------------
The array now has 3 elements.

The index of the last element is 2.

Element #3 is `'.
#-----------------------------
$#people = 10_000;
what_about_that_array();
#-----------------------------
The array now has 10001 elements.

The index of the last element is 10000.

Element #3 is `'.
#-----------------------------
$people[10_000] = undef;
#-----------------------------

# ^^PLEAC^^_4.4
#-----------------------------
foreach $item (LIST) {
    # do something with $item
}
#-----------------------------
foreach $user (@bad_users) {
        complain($user);
}
#-----------------------------
foreach $var (sort keys %ENV) {
    print "$var=$ENV{$var}\n";
}
#-----------------------------
foreach $user (@all_users) {
    $disk_space = get_usage($user);     # find out how much disk space in use
    if ($disk_space > $MAX_QUOTA) {     # if it's more than we want ...
        complain($user);                # ... then object vociferously
    }
}
#-----------------------------
foreach (`who`) {
    if (/tchrist/) {
        print;
    }
}
#-----------------------------
while (<FH>) {              # $_ is set to the line just read
    chomp;                  # $_ has a trailing \n removed, if it had one
    foreach (split) {       # $_ is split on whitespace, into @_
                            # then $_ is set to each chunk in turn
        $_ = reverse;       # the characters in $_ are reversed
        print;              # $_ is printed
    }
}
#-----------------------------
foreach my $item (@array) {
    print "i = $item\n";
}
#-----------------------------
@array = (1,2,3);
foreach $item (@array) {
    $item--;
}
print "@array\n";
0 1 2


# multiply everything in @a and @b by seven
@a = ( .5, 3 ); @b =( 0, 1 );
foreach $item (@a, @b) {
    $item *= 7;
}
print "@a @b\n";
3.5 21 0 7
#-----------------------------
# trim whitespace in the scalar, the array, and all the values
# in the hash
foreach ($scalar, @array, @hash{keys %hash}) {
    s/^\s+//;
    s/\s+$//;
}
#-----------------------------
for $item (@array) {  # same as foreach $item (@array)
    # do something
}

for (@array)      {   # same as foreach $_ (@array)
    # do something
}
#-----------------------------

# ^^PLEAC^^_4.5
#-----------------------------
# iterate over elements of array in $ARRAYREF
foreach $item (@$ARRAYREF) {
    # do something with $item
}

for ($i = 0; $i <= $#$ARRAYREF; $i++) {
    # do something with $ARRAYREF->[$i]
}
#-----------------------------
@fruits = ( "Apple", "Blackberry" );
$fruit_ref = \@fruits;
foreach $fruit (@$fruit_ref) {
    print "$fruit tastes good in a pie.\n";
}
Apple tastes good in a pie.

Blackberry tastes good in a pie.
#-----------------------------
for ($i=0; $i <= $#$fruit_ref; $i++) {
    print "$fruit_ref->[$i] tastes good in a pie.\n";
}
#-----------------------------
$namelist{felines} = \@rogue_cats;
foreach $cat ( @{ $namelist{felines} } ) {
    print "$cat purrs hypnotically..\n";
}
print "--More--\nYou are controlled.\n";
#-----------------------------
for ($i=0; $i <= $#{ $namelist{felines} }; $i++) {
    print "$namelist{felines}[$i] purrs hypnotically.\n";
}
#-----------------------------

# ^^PLEAC^^_4.6
#-----------------------------
%seen = ();
@uniq = ();
foreach $item (@list) {
    unless ($seen{$item}) {
        # if we get here, we have not seen it before
        $seen{$item} = 1;
        push(@uniq, $item);
    }
}
#-----------------------------
%seen = ();
foreach $item (@list) {
    push(@uniq, $item) unless $seen{$item}++;
}
#-----------------------------
%seen = ();
foreach $item (@list) {
    some_func($item) unless $seen{$item}++;
}
#-----------------------------
%seen = ();
foreach $item (@list) {
    $seen{$item}++;
}
@uniq = keys %seen;
#-----------------------------
%seen = ();
@uniqu = grep { ! $seen{$_} ++ } @list;
#-----------------------------
# generate a list of users logged in, removing duplicates
%ucnt = ();
for (`who`) {
    s/\s.*\n//;   # kill from first space till end-of-line, yielding username
    $ucnt{$_}++;  # record the presence of this user
}
# extract and print unique keys
@users = sort keys %ucnt;
print "users logged in: @users\n";
#-----------------------------

# ^^PLEAC^^_4.7
#-----------------------------
# assume @A and @B are already loaded
%seen = ();                  # lookup table to test membership of B
@aonly = ();                 # answer

# build lookup table
foreach $item (@B) { $seen{$item} = 1 }

# find only elements in @A and not in @B
foreach $item (@A) {
    unless ($seen{$item}) {
        # it's not in %seen, so add to @aonly
        push(@aonly, $item);
    }
}
#-----------------------------
my %seen; # lookup table
my @aonly;# answer

# build lookup table
@seen{@B} = ();

foreach $item (@A) {
    push(@aonly, $item) unless exists $seen{$item};
}
#-----------------------------
foreach $item (@A) {
    push(@aonly, $item) unless $seen{$item};
    $seen{$item} = 1;                       # mark as seen
}
#-----------------------------
$hash{"key1"} = 1;
$hash{"key2"} = 2;
#-----------------------------
@hash{"key1", "key2"} = (1,2);
#-----------------------------
@seen{@B} = ();
#-----------------------------
@seen{@B} = (1) x @B;
#-----------------------------

# ^^PLEAC^^_4.8
#-----------------------------
@a = (1, 3, 5, 6, 7, 8);
@b = (2, 3, 5, 7, 9);

@union = @isect = @diff = ();
%union = %isect = ();
%count = ();
#-----------------------------
foreach $e (@a) { $union{$e} = 1 }

foreach $e (@b) {
    if ( $union{$e} ) { $isect{$e} = 1 }
    $union{$e} = 1;
}
@union = keys %union;
@isect = keys %isect;
#-----------------------------
foreach $e (@a, @b) { $union{$e}++ && $isect{$e}++ }

@union = keys %union;
@isect = keys %isect;
#-----------------------------
foreach $e (@a, @b) { $count{$e}++ }

foreach $e (keys %count) {
    push(@union, $e);
    if ($count{$e} == 2) {
        push @isect, $e;
    } else {
        push @diff, $e;
    }
}
#-----------------------------
@isect = @diff = @union = ();

foreach $e (@a, @b) { $count{$e}++ }

foreach $e (keys %count) {
    push(@union, $e);
    push @{ $count{$e} == 2 ? \@isect : \@diff }, $e;
}
#-----------------------------

# ^^PLEAC^^_4.9
#-----------------------------
# push
push(@ARRAY1, @ARRAY2);
#-----------------------------
@ARRAY1 = (@ARRAY1, @ARRAY2);
#-----------------------------
@members = ("Time", "Flies");
@initiates = ("An", "Arrow");
push(@members, @initiates);
# @members is now ("Time", "Flies", "An", "Arrow")
#-----------------------------
splice(@members, 2, 0, "Like", @initiates);
print "@members\n";
splice(@members, 0, 1, "Fruit");
splice(@members, -2, 2, "A", "Banana");
print "@members\n";
#-----------------------------
Time Flies Like An Arrow

Fruit Flies Like A Banana
#-----------------------------

# ^^PLEAC^^_4.10
#-----------------------------
# reverse @ARRAY into @REVERSED
@REVERSED = reverse @ARRAY;
#-----------------------------
for ($i = $#ARRAY; $i >= 0; $i--) {
    # do something with $ARRAY[$i]
}
#-----------------------------
# two-step: sort then reverse
@ascending = sort { $a cmp $b } @users;
@descending = reverse @ascending;

# one-step: sort with reverse comparison
@descending = sort { $b cmp $a } @users;
#-----------------------------

# ^^PLEAC^^_4.11
#-----------------------------
# remove $N elements from front of @ARRAY (shift $N)
@FRONT = splice(@ARRAY, 0, $N);

# remove $N elements from the end of the array (pop $N)
@END = splice(@ARRAY, -$N);
#-----------------------------
sub shift2 (\@) {
    return splice(@{$_[0]}, 0, 2);
}

sub pop2 (\@) {
    return splice(@{$_[0]}, -2);
}
#-----------------------------
@friends = qw(Peter Paul Mary Jim Tim);
($this, $that) = shift2(@friends);
# $this contains Peter, $that has Paul, and
# @friends has Mary, Jim, and Tim

@beverages = qw(Dew Jolt Cola Sprite Fresca);
@pair = pop2(@beverages);
# $pair[0] contains Sprite, $pair[1] has Fresca,
# and @beverages has (Dew, Jolt, Cola)
#-----------------------------
$line[5] = \@list;
@got = pop2( @{ $line[5] } );
#-----------------------------

# ^^PLEAC^^_4.12
#-----------------------------
my($match, $found, $item);
foreach $item (@array) {
    if ($criterion) {
        $match = $item;  # must save
        $found = 1;
        last;
    }
}
if ($found) {
    ## do something with $match
} else {
    ## unfound
}
#-----------------------------
my($i, $match_idx);
for ($i = 0; $i < @array; $i++) {
    if ($criterion) {
        $match_idx = $i;    # save the index
        last;
    }
}

if (defined $match_idx) {
    ## found in $array[$match_idx]
} else {
    ## unfound
}
#-----------------------------
foreach $employee (@employees) {
    if ( $employee->category() eq 'engineer' ) {
        $highest_engineer = $employee;
        last;
    }
}
print "Highest paid engineer is: ", $highest_engineer->name(), "\n";
#-----------------------------
for ($i = 0; $i < @ARRAY; $i++) {
    last if $criterion;
}
if ($i < @ARRAY) {
    ## found and $i is the index
} else {
    ## not found
}
#-----------------------------

# ^^PLEAC^^_4.13
#-----------------------------
@MATCHING = grep { TEST ($_) } @LIST;
#-----------------------------
@matching = ();
foreach (@list) {
    push(@matching, $_) if TEST ($_);
}
#-----------------------------
@bigs = grep { $_ > 1_000_000 } @nums;
@pigs = grep { $users{$_} > 1e7 } keys %users;
#-----------------------------
@matching = grep { /^gnat / } `who`;
#-----------------------------
@engineers = grep { $_->position() eq 'Engineer' } @employees;
#-----------------------------
@secondary_assistance = grep { $_->income >= 26_000 &&
                               $_->income <  30_000 }
                        @applicants;
#-----------------------------

# ^^PLEAC^^_4.14
#-----------------------------
@sorted = sort { $a <=> $b } @unsorted;
#-----------------------------
# @pids is an unsorted array of process IDs
foreach my $pid (sort { $a <=> $b } @pids) {
    print "$pid\n";
}
print "Select a process ID to kill:\n";
chomp ($pid = <>);
die "Exiting ... \n" unless $pid && $pid =~ /^\d+$/;
kill('TERM',$pid);
sleep 2;
kill('KILL',$pid);
#-----------------------------
@descending = sort { $b <=> $a } @unsorted;
#-----------------------------
package Sort_Subs;
sub revnum { $b <=> $a }

package Other_Pack;
@all = sort Sort_Subs::revnum 4, 19, 8, 3;
#-----------------------------
@all = sort { $b <=> $a } 4, 19, 8, 3;
#-----------------------------

# ^^PLEAC^^_4.15
#-----------------------------
@ordered = sort { compare() } @unordered;
#-----------------------------
@precomputed = map { [compute(),$_] } @unordered;
@ordered_precomputed = sort { $a->[0] <=> $b->[0] } @precomputed;
@ordered = map { $_->[1] } @ordered_precomputed;
#-----------------------------
@ordered = map { $_->[1] }
           sort { $a->[0] <=> $b->[0] }
           map { [compute(), $_] }
           @unordered;
#-----------------------------
@ordered = sort { $a->name cmp $b->name } @employees;
#-----------------------------
foreach $employee (sort { $a->name cmp $b->name } @employees) {
    print $employee->name, " earns \$", $employee->salary, "\n";
}
#-----------------------------
@sorted_employees = sort { $a->name cmp $b->name } @employees;
foreach $employee (@sorted_employees) {
    print $employee->name, " earns \$", $employee->salary, "\n";
}
# load %bonus
foreach $employee (@sorted_employees) {
    if ( $bonus{ $employee->ssn } ) {
      print $employee->name, " got a bonus!\n";
    }
}
#-----------------------------
@sorted = sort { $a->name cmp $b->name
                           ||
                  $b->age <=> $a->age } @employees;
#-----------------------------
use User::pwent qw(getpwent);
@users = ();
# fetch all users
while (defined($user = getpwent)) {
    push(@users, $user);
}
    @users = sort { $a->name cmp $b->name } @users;
foreach $user (@users) {
    print $user->name, "\n";
}
#-----------------------------
@sorted = sort { substr($a,1,1) cmp substr($b,1,1) } @names;
#-----------------------------
@sorted = sort { length $a <=> length $b } @strings;
#-----------------------------
@temp   = map  { [ length $_, $_ ] } @strings;
@temp   = sort { $a->[0] <=> $b->[0] } @temp;
@sorted = map  { $_->[1] } @temp;
#-----------------------------
@sorted = map  { $_->[1] }
          sort { $a->[0] <=> $b->[0] }
          map  { [ length $_, $_ ] }
          @strings;
#-----------------------------
@temp          = map  { [ /(\d+)/, $_ ] } @fields;
@sorted_temp   = sort { $a->[0] <=> $b->[0] } @temp;
@sorted_fields = map  { $_->[1] } @sorted_temp;
#-----------------------------
@sorted_fields = map  { $_->[1] }
                 sort { $a->[0] <=> $b->[0] }
                 map  { [ /(\d+)/, $_ ] }
                 @fields;
#-----------------------------
print map  { $_->[0] }             # whole line
      sort {
              $a->[1] <=> $b->[1]  # gid
                      ||
              $a->[2] <=> $b->[2]  # uid
                      ||
              $a->[3] cmp $b->[3]  # login
      }
      map  { [ $_, (split /:/)[3,2,0] ] }
      `cat /etc/passwd`;
#-----------------------------

# ^^PLEAC^^_4.16
#-----------------------------
unshift(@circular, pop(@circular));  # the last shall be first
push(@circular, shift(@circular));   # and vice versa
#-----------------------------
sub grab_and_rotate ( \@ ) {
    my $listref = shift;
    my $element = $listref->[0];
    push(@$listref, shift @$listref);
    return $element;
}

@processes = ( 1, 2, 3, 4, 5 );
while (1) {
    $process = grab_and_rotate(@processes);
    print "Handling process $process\n";
    sleep 1;
}
#-----------------------------

# ^^PLEAC^^_4.17
#-----------------------------
# fisher_yates_shuffle( \@array ) : generate a random permutation
# of @array in place
sub fisher_yates_shuffle {
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
}

fisher_yates_shuffle( \@array );    # permutes @array in place
#-----------------------------
$permutations = factorial( scalar @array );
@shuffle = @array [ n2perm( 1+int(rand $permutations), $#array ) ];
#-----------------------------
sub naive_shuffle {                             # don't do this
    for (my $i = 0; $i < @_; $i++) {
        my $j = int rand @_;                    # pick random element
        ($_[$i], $_[$j]) = ($_[$j], $_[$i]);    # swap 'em
    }
}
#-----------------------------

# ^^PLEAC^^_4.18
#-----------------------------
awk      cp       ed       login    mount    rmdir    sum
basename csh      egrep    ls       mt       sed      sync
cat      date     fgrep    mail     mv       sh       tar
chgrp    dd       grep     mkdir    ps       sort     touch
chmod    df       kill     mknod    pwd      stty     vi
chown    echo     ln       more     rm       su
#-----------------------------
# ^^INCLUDE^^ include/perl/ch04/words
#-----------------------------
#Wrong       Right
#-----       -----
#1 2 3       1 4 7
#4 5 6       2 5 8
#7 8 9       3 6 9
#-----------------------------

# ^^PLEAC^^_4.19
#-----------------------------
#% echo man bites dog | permute
#dog bites man
#
#bites dog man
#
#dog man bites
#
#man dog bites
#
#bites man dog
#
#man bites dog
#-----------------------------
#Set Size            Permutations
#1                   1
#2                   2
#3                   6
#4                   24
#5                   120
#6                   720
#7                   5040
#8                   40320
#9                   362880
#10                  3628800
#11                  39916800
#12                  479001600
#13                  6227020800
#14                  87178291200
#15                  1307674368000
#-----------------------------
use Math::BigInt;
    sub factorial {
    my $n = shift;
    my $s = 1;
    $s *= $n-- while $n > 0;
    return $s;
}
print factorial(Math::BigInt->new("500"));
+1220136... (1035 digits total)
#-----------------------------
# ^^INCLUDE^^ include/perl/ch04/permute
#-----------------------------
# ^^INCLUDE^^ include/perl/ch04/mjd_permute
#-----------------------------

# ^^PLEAC^^_5.0
#-----------------------------
%age = ( "Nat",   24,
         "Jules", 25,
         "Josh",  17  );
#-----------------------------
$age{"Nat"}   = 24;
$age{"Jules"} = 25;
$age{"Josh"}  = 17;
#-----------------------------
%food_color = (
               "Apple"  => "red",
               "Banana" => "yellow",
               "Lemon"  => "yellow",
               "Carrot" => "orange"
              );
#-----------------------------
%food_color = (
                Apple  => "red",
                Banana => "yellow",
                Lemon  => "yellow",
                Carrot => "orange"
               );
#-----------------------------

# ^^PLEAC^^_5.1
#-----------------------------
$HASH{$KEY} = $VALUE;
#-----------------------------
# %food_color defined per the introduction
$food_color{Raspberry} = "pink";
print "Known foods:\n";
foreach $food (keys %food_color) {
    print "$food\n";
}

# Known foods:
# 
# Banana
# 
# Apple
# 
# Raspberry
# 
# Carrot
# 
# Lemon
#-----------------------------

# ^^PLEAC^^_5.2
#-----------------------------
# does %HASH have a value for $KEY ?
if (exists($HASH{$KEY})) {
    # it exists
} else {
    # it doesn't
}
#-----------------------------
# %food_color per the introduction
foreach $name ("Banana", "Martini") {
    if (exists $food_color{$name}) {
        print "$name is a food.\n";
    } else {
        print "$name is a drink.\n";
    }
}

# Banana is a food.
# 
# Martini is a drink.
#-----------------------------
%age = ();
$age{"Toddler"}  = 3;
$age{"Unborn"}   = 0;
$age{"Phantasm"} = undef;

foreach $thing ("Toddler", "Unborn", "Phantasm", "Relic") {
    print "$thing: ";
    print "Exists " if exists $age{$thing};
    print "Defined " if defined $age{$thing};
    print "True " if $age{$thing};
    print "\n";
}

# Toddler: Exists Defined True 
# 
# Unborn: Exists Defined 
# 
# Phantasm: Exists 
# 
# Relic: 
#-----------------------------
%size = ();
while (<>) {
    chomp;
    next if $size{$_};              # WRONG attempt to skip
    $size{$_} = -s $_;
}
#-----------------------------
    next if exists $size{$_};
#-----------------------------

# ^^PLEAC^^_5.3
#-----------------------------
# remove $KEY and its value from %HASH
delete($HASH{$KEY});
#-----------------------------
# %food_color as per Introduction
sub print_foods {
    my @foods = keys %food_color;
    my $food;

    print "Keys: @foods\n";
    print "Values: ";

    foreach $food (@foods) {
        my $color = $food_color{$food};

        if (defined $color) {
            print "$color ";
        } else {
            print "(undef) ";
        }
    }
    print "\n";
}

print "Initially:\n";
print_foods();


print "\nWith Banana undef\n";
undef $food_color{"Banana"};
print_foods();


print "\nWith Banana deleted\n";
delete $food_color{"Banana"};
print_foods();


# Initially:
# 
# Keys: Banana Apple Carrot Lemon
# 
# Values: yellow red orange yellow 
# 
# 
# With Banana undef
# 
# Keys: Banana Apple Carrot Lemon
# 
# Values: (undef) red orange yellow 
# 
# 
# With Banana deleted
# 
# Keys: Apple Carrot Lemon
# 
# Values: red orange yellow 
#-----------------------------
delete @food_color{"Banana", "Apple", "Cabbage"};
#-----------------------------

# ^^PLEAC^^_5.4
#-----------------------------
while(($key, $value) = each(%HASH)) {
    # do something with $key and $value
}
#-----------------------------
foreach $key (keys %HASH) {
    $value = $HASH{$key};
    # do something with $key and $value
}
#-----------------------------
# %food_color per the introduction
while(($food, $color) = each(%food_color)) {
    print "$food is $color.\n";
}
# Banana is yellow.
# 
# Apple is red.
# 
# Carrot is orange.
# 
# Lemon is yellow.

foreach $food (keys %food_color) {
    my $color = $food_color{$food};
    print "$food is $color.\n";
}
# Banana is yellow.
# 
# Apple is red.
# 
# Carrot is orange.
# 
# Lemon is yellow.
#-----------------------------
print
 
"$food
 
is
 
$food_color{$food}.\n"
 
#-----------------------------
foreach $food (sort keys %food_color) {
    print "$food is $food_color{$food}.\n";
}
# Apple is red.
# 
# Banana is yellow.
# 
# Carrot is orange.
# 
# Lemon is yellow.
#-----------------------------
while ( ($k,$v) = each %food_color ) {
    print "Processing $k\n";
    keys %food_color;               # goes back to the start of %food_color
}
#-----------------------------
# ^^INCLUDE^^ include/perl/ch05/countfrom
#-----------------------------

# ^^PLEAC^^_5.5
#-----------------------------
while ( ($k,$v) = each %hash ) {
    print "$k => $v\n";
}
#-----------------------------
print map { "$_ => $hash{$_}\n" } keys %hash;
#-----------------------------
print "@{[ %hash ]}\n";
#-----------------------------
{
    my @temp = %hash;
    print "@temp";
}
#-----------------------------
foreach $k (sort keys %hash) {
    print "$k => $hash{$k}\n";
}
#-----------------------------

# ^^PLEAC^^_5.6
#-----------------------------
use Tie::IxHash;
tie %HASH, "Tie::IxHash";
# manipulate %HASH
@keys = keys %HASH;         # @keys is in insertion order
#-----------------------------
# initialize
use Tie::IxHash;

tie %food_color, "Tie::IxHash";
$food_color{Banana} = "Yellow";
$food_color{Apple}  = "Green";
$food_color{Lemon}  = "Yellow";

print "In insertion order, the foods are:\n";
foreach $food (keys %food_color) {
    print "  $food\n";
}

print "Still in insertion order, the foods' colors are:\n";
while (( $food, $color ) = each %food_color ) {
    print "$food is colored $color.\n";
}

#In insertion order, the foods are:
#
#  Banana
#
#  Apple
#
#  Lemon
#
#Still in insertion order, the foods' colors are:
#
#Banana is colored Yellow.
#
#Apple is colored Green.
#
#Lemon is colored Yellow.
#-----------------------------

# ^^PLEAC^^_5.7
#-----------------------------
%ttys = ();

open(WHO, "who|")                   or die "can't open who: $!";
while (<WHO>) {
    ($user, $tty) = split;
    push( @{$ttys{$user}}, $tty );
}

foreach $user (sort keys %ttys) {
    print "$user: @{$ttys{$user}}\n";
}
#-----------------------------
foreach $user (sort keys %ttys) {
    print "$user: ", scalar( @{$ttys{$user}} ), " ttys.\n";
    foreach $tty (sort @{$ttys{$user}}) {
        @stat = stat("/dev/$tty");
        $user = @stat ? ( getpwuid($stat[4]) )[0] : "(not available)";
        print "\t$tty (owned by $user)\n";
    }
}
#-----------------------------
sub multihash_delete {
    my ($hash, $key, $value) = @_;
    my $i;

    return unless ref( $hash->{$key} );
    for ($i = 0; $i < @{ $hash->{$key} }; $i++) {
        if ($hash->{$key}->[$i] eq $value) {
            splice( @{$hash->{$key}}, $i, 1);
            last;
        }
    }

    delete $hash->{$key} unless @{$hash->{$key}};
}
#-----------------------------

# ^^PLEAC^^_5.8
#-----------------------------
# %LOOKUP maps keys to values
%REVERSE = reverse %LOOKUP;
#-----------------------------
%surname = ( "Mickey" => "Mantle", "Babe" => "Ruth" );
%first_name = reverse %surname;
print $first_name{"Mantle"}, "\n";
Mickey
#-----------------------------
("Mickey", "Mantle", "Babe", "Ruth")
#-----------------------------
("Ruth", "Babe", "Mantle", "Mickey")
#-----------------------------
("Ruth" => "Babe", "Mantle" => "Mickey")
#-----------------------------
# ^^INCLUDE^^ include/perl/ch05/foodfind
#-----------------------------
# %food_color as per the introduction
while (($food,$color) = each(%food_color)) {
    push(@{$foods_with_color{$color}}, $food);
}

print "@{$foods_with_color{yellow}} were yellow foods.\n";
# Banana Lemon were yellow foods.
#-----------------------------

# ^^PLEAC^^_5.9
#-----------------------------
# %HASH is the hash to sort
@keys = sort { criterion() } (keys %hash);
foreach $key (@keys) {
    $value = $hash{$key};
    # do something with $key, $value
}
#-----------------------------
foreach $food (sort keys %food_color) {
    print "$food is $food_color{$food}.\n";
}
#-----------------------------
foreach $food (sort { $food_color{$a} cmp $food_color{$b} }
                keys %food_color) 
{
    print "$food is $food_color{$food}.\n";
}
#-----------------------------
@foods = sort { length($food_color{$a}) <=> length($food_color{$b}) } 
    keys %food_color;
foreach $food (@foods) {
    print "$food is $food_color{$food}.\n";
}
#-----------------------------

# ^^PLEAC^^_5.10
#-----------------------------
%merged = (%A, %B);
#-----------------------------
%merged = ();
while ( ($k,$v) = each(%A) ) {
    $merged{$k} = $v;
}
while ( ($k,$v) = each(%B) ) {
    $merged{$k} = $v;
}
#-----------------------------
# %food_color as per the introduction
%drink_color = ( Galliano  => "yellow",
                 "Mai Tai" => "blue" );

%ingested_color = (%drink_color, %food_color);
#-----------------------------
# %food_color per the introduction, then
%drink_color = ( Galliano  => "yellow",
                 "Mai Tai" => "blue" );

%substance_color = ();
while (($k, $v) = each %food_color) {
    $substance_color{$k} = $v;
} 
while (($k, $v) = each %drink_color) {
    $substance_color{$k} = $v;
} 
#-----------------------------
foreach $substanceref ( \%food_color, \%drink_color ) {
    while (($k, $v) = each %$substanceref) {
        $substance_color{$k} = $v;
    }
}
#-----------------------------
foreach $substanceref ( \%food_color, \%drink_color ) {
    while (($k, $v) = each %$substanceref) {
        if (exists $substance_color{$k}) {
            print "Warning: $k seen twice.  Using the first definition.\n";
            next;
        }
        $substance_color{$k} = $v;
    }
}
#-----------------------------
@all_colors{keys %new_colors} = values %new_colors;
#-----------------------------

# ^^PLEAC^^_5.11
#-----------------------------
my @common = ();
foreach (keys %hash1) {
    push(@common, $_) if exists $hash2{$_};
}
# @common now contains common keys
#-----------------------------
my @this_not_that = ();
foreach (keys %hash1) {
    push(@this_not_that, $_) unless exists $hash2{$_};
}
#-----------------------------
# %food_color per the introduction

# %citrus_color is a hash mapping citrus food name to its color.
%citrus_color = ( Lemon  => "yellow",
                  Orange => "orange",
                  Lime   => "green" );

# build up a list of non-citrus foods
@non_citrus = ();

foreach (keys %food_color) {
    push (@non_citrus, $_) unless exists $citrus_color{$_};
}
#-----------------------------

# ^^PLEAC^^_5.12
#-----------------------------
use Tie::RefHash;
tie %hash, "Tie::RefHash";
# you may now use references as the keys to %hash
#-----------------------------
# Class::Somewhere=HASH(0x72048)
# 
# ARRAY(0x72048)
#-----------------------------
use Tie::RefHash;
use IO::File;

tie %name, "Tie::RefHash";
foreach $filename ("/etc/termcap", "/vmunix", "/bin/cat") {
    $fh = IO::File->new("< $filename") or next;
    $name{$fh} = $filename;
}
print "open files: ", join(", ", values %name), "\n";
foreach $file (keys %name) {
    seek($file, 0, 2);      # seek to the end
    printf("%s is %d bytes long.\n", $name{$file}, tell($file));
}
#-----------------------------

# ^^PLEAC^^_5.13
#-----------------------------
# presize %hash to $num
keys(%hash) = $num;
#-----------------------------
# will have 512 users in %users
keys(%users) = 512;
#-----------------------------
keys(%users) = 1000;
#-----------------------------

# ^^PLEAC^^_5.14
#-----------------------------
%count = ();
foreach $element (@ARRAY) {
    $count{$element}++;
}
#-----------------------------

# ^^PLEAC^^_5.15
#-----------------------------
%father = ( 'Cain'      => 'Adam',
            'Abel'      => 'Adam',
            'Seth'      => 'Adam',
            'Enoch'     => 'Cain',
            'Irad'      => 'Enoch',
            'Mehujael'  => 'Irad',
            'Methusael' => 'Mehujael',
            'Lamech'    => 'Methusael',
            'Jabal'     => 'Lamech',
            'Jubal'     => 'Lamech',
            'Tubalcain' => 'Lamech',
            'Enos'      => 'Seth' );
#-----------------------------
while (<>) {
    chomp;
    do {
        print "$_ ";        # print the current name
        $_ = $father{$_};   # set $_ to $_'s father
    } while defined;        # until we run out of fathers
    print "\n";
}
#-----------------------------
while ( ($k,$v) = each %father ) {
    push( @{ $children{$v} }, $k );
}

$" = ', ';                  # separate output with commas
while (<>) {
    chomp;
    if ($children{$_}) {
        @children = @{$children{$_}};
    } else {
        @children = "nobody";
    }
    print "$_ begat @children.\n";
}
#-----------------------------
foreach $file (@files) {
    local *F;               # just in case we want a local FH
    unless (open (F, "<$file")) {
        warn "Couldn't read $file: $!; skipping.\n";
        next;
    }
    
    while (<F>) {
        next unless /^\s*#\s*include\s*<([^>]+)>/;
        push(@{$includes{$1}}, $file);
    }
    close F;
}
#-----------------------------
@include_free = ();                 # list of files that don't include others
@uniq{map { @$_ } values %includes} = undef;
foreach $file (sort keys %uniq) {
        push( @include_free , $file ) unless $includes{$file};
}
#-----------------------------

# ^^PLEAC^^_5.16
#-----------------------------
#% du pcb
#19      pcb/fix
#
#20      pcb/rev/maybe/yes
#
#10      pcb/rev/maybe/not
#
#705     pcb/rev/maybe
#
#54      pcb/rev/web
#
#1371    pcb/rev
#
#3       pcb/pending/mine
#
#1016    pcb/pending
#
#2412    pcb
#-----------------------------
#2412 pcb
#
#   
#|
#    1371 rev
#
#   
#|       |
#    705 maybe
#
#   
#|       |      |
#      675 .
#
#   
#|       |      |
#	20 yes
#
#   
#|       |      |
#	10 not
#
#   
#|       |
#    612 .
#
#   
#|       |
#     54 web
#
#   
#|
#    1016 pending
#
#   
#|       |
#	 1013 .
#
#   
#|       |
#	    3 mine
#
#   
#|
#      19 fix
#
#   
#|
#	6 .
#-----------------------------
#% dutree
#% dutree /usr
#% dutree -a 
#% dutree -a /bin
#-----------------------------
# ^^INCLUDE^^ include/perl/ch05/dutree
#-----------------------------
# ^^INCLUDE^^ include/perl/ch05/dutree-orig
#-----------------------------

# ^^PLEAC^^_6.0
#-----------------------------
match( $string, $pattern );
subst( $string, $pattern, $replacement );
#-----------------------------
$meadow =~ m/sheep/;   # True if $meadow contains "sheep"
$meadow !~ m/sheep/;   # True if $meadow doesn't contain "sheep"
$meadow =~ s/old/new/; # Replace "old" with "new" in $meadow
#-----------------------------
# Fine bovines demand fine toreadors.
# Muskoxen are a polar ovibovine species.
# Grooviness went out of fashion decades ago.
#-----------------------------
# Ovines are found typically in oviaries.
#-----------------------------
if ($meadow =~ /\bovines?\b/i) { print "Here be sheep!" }
#-----------------------------
$string = "good food";
$string =~ s/o*/e/;
#-----------------------------
# good food
# 
# geod food
# 
# geed food
# 
# geed feed
# 
# ged food
# 
# ged fed
# 
# egood food
#-----------------------------
#% echo ababacaca | perl -ne 'print "$&\n" if /(a|ba|b)+(a|ac)+/'
#ababa
#-----------------------------
#% echo ababacaca | 
#    awk 'match($0,/(a|ba|b)+(a|ac)+/) { print substr($0, RSTART, RLENGTH) }'
#ababacaca
#-----------------------------
while (m/(\d+)/g) {
    print "Found number $1\n";
}
#-----------------------------
@numbers = m/(\d+)/g;
#-----------------------------
$digits = "123456789";
@nonlap = $digits =~ /(\d\d\d)/g;
@yeslap = $digits =~ /(?=(\d\d\d))/g;
print "Non-overlapping:  @nonlap\n";
print "Overlapping:      @yeslap\n";
# Non-overlapping:  123 456 789

# Overlapping:      123 234 345 456 567 678 789
#-----------------------------
$string = "And little lambs eat ivy";
$string =~ /l[^s]*s/;
print "($`) ($&) ($')\n";
# (And ) (little lambs) ( eat ivy)
#-----------------------------

# ^^PLEAC^^_6.1
#-----------------------------
$dst = $src;
$dst =~ s/this/that/;
#-----------------------------
($dst = $src) =~ s/this/that/;
#-----------------------------
# strip to basename
($progname = $0)        =~ s!^.*/!!;

# Make All Words Title-Cased
($capword  = $word)     =~ s/(\w+)/\u\L$1/g;

# /usr/man/man3/foo.1 changes to /usr/man/cat3/foo.1
($catpage  = $manpage)  =~ s/man(?=\d)/cat/;
#-----------------------------
@bindirs = qw( /usr/bin /bin /usr/local/bin );
for (@libdirs = @bindirs) { s/bin/lib/ }
print "@libdirs\n";
# /usr/lib /lib /usr/local/lib
#-----------------------------
($a =  $b) =~ s/x/y/g;      # copy $b and then change $a
 $a = ($b  =~ s/x/y/g);     # change $b, count goes in $a
#-----------------------------

# ^^PLEAC^^_6.2
#-----------------------------
if ($var =~ /^[A-Za-z]+$/) {
    # it is purely alphabetic
}
#-----------------------------
use locale;
if ($var =~ /^[^\W\d_]+$/) {
    print "var is purely alphabetic\n";
}
#-----------------------------
use locale;
use POSIX 'locale_h';

# the following locale string might be different on your system
unless (setlocale(LC_ALL, "fr_CA.ISO8859-1")) {
    die "couldn't set locale to French Canadian\n";
}

while (<DATA>) {
    chomp;
    if (/^[^\W\d_]+$/) {
        print "$_: alphabetic\n";
    } else {
        print "$_: line noise\n";
    }
}

#__END__
#silly
#façade
#coöperate
#niño
#Renée
#Molière
#hæmoglobin
#naïve
#tschüß
#random!stuff#here
#-----------------------------

# ^^PLEAC^^_6.3
#-----------------------------
#/\S+/               # as many non-whitespace bytes as possible
#/[A-Za-z'-]+/       # as many letters, apostrophes, and hyphens
#-----------------------------
#/\b([A-Za-z]+)\b/            # usually best
#/\s([A-Za-z]+)\s/            # fails at ends or w/ punctuation
#-----------------------------

# ^^PLEAC^^_6.4
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/resname
#-----------------------------
s/                  # replace
  \#                #   a pound sign
  (\w+)             #   the variable name
  \#                #   another pound sign
/${$1}/xg;          # with the value of the global variable
##-----------------------------
s/                  # replace
\#                  #   a pound sign
(\w+)               #   the variable name
\#                  #   another pound sign
/'$' . $1/xeeg;     # ' with the value of *any* variable
#-----------------------------

# ^^PLEAC^^_6.5
#-----------------------------
# One fish two fish red fish blue fish
#-----------------------------
$WANT = 3;
$count = 0;
while (/(\w+)\s+fish\b/gi) {
    if (++$count == $WANT) {
        print "The third fish is a $1 one.\n";
        # Warning: don't `last' out of this loop
    }
}
# The third fish is a red one.
#-----------------------------
/(?:\w+\s+fish\s+){2}(\w+)\s+fish/i;
#-----------------------------
# simple way with while loop
$count = 0;
while ($string =~ /PAT/g) {
    $count++;               # or whatever you'd like to do here
}

# same thing with trailing while
$count = 0;
$count++ while $string =~ /PAT/g;

# or with for loop
for ($count = 0; $string =~ /PAT/g; $count++) { }
    
# Similar, but this time count overlapping matches
$count++ while $string =~ /(?=PAT)/g;
#-----------------------------
$pond  = 'One fish two fish red fish blue fish';

# using a temporary
@colors = ($pond =~ /(\w+)\s+fish\b/gi);      # get all matches
$color  = $colors[2];                         # then the one we want

# or without a temporary array
$color = ( $pond =~ /(\w+)\s+fish\b/gi )[2];  # just grab element 3

print "The third fish in the pond is $color.\n";
# The third fish in the pond is red.
#-----------------------------
$count = 0;
$_ = 'One fish two fish red fish blue fish';
@evens = grep { $count++ % 2 == 1 } /(\w+)\s+fish\b/gi;
print "Even numbered fish are @evens.\n";
# Even numbered fish are two blue.
#-----------------------------
$count = 0;
s{
   \b               # makes next \w more efficient
   ( \w+ )          # this is what we'll be changing
   (
     \s+ fish \b
   )
}{
    if (++$count == 4) {
        "sushi" . $2;
    } else {
         $1   . $2;
    }
}gex;
# One fish two fish red fish sushi fish
#-----------------------------
$pond = 'One fish two fish red fish blue fish swim here.';
$color = ( $pond =~ /\b(\w+)\s+fish\b/gi )[-1];
print "Last fish is $color.\n";
# Last fish is blue.
#-----------------------------
m{
    A               # find some pattern A
    (?!             # mustn't be able to find
        .*          # something
        A           # and A
    )
    $               # through the end of the string
}x
#-----------------------------
$pond = 'One fish two fish red fish blue fish swim here.';
if ($pond =~ m{
                    \b  (  \w+) \s+ fish \b
                (?! .* \b fish \b )
            }six )
{
    print "Last fish is $1.\n";
} else {
    print "Failed!\n";
}
# Last fish is blue.
#-----------------------------

# ^^PLEAC^^_6.6
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/killtags
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/headerfy
#-----------------------------
#% perl -00pe 's{\A(Chapter\s+\d+\s*:.*)}{<H1>$1</H1>}gx' datafile
#-----------------------------
$/ = '';            # paragraph read mode for readline access
while (<ARGV>) {
    while (m#^START(.*?)^END#sm) {  # /s makes . span line boundaries
                                    # /m makes ^ match near newlines
        print "chunk $. in $ARGV has <<$1>>\n";
    }
}
#-----------------------------

# ^^PLEAC^^_6.7
#-----------------------------
undef $/;
@chunks = split(/pattern/, <FILEHANDLE>);
#-----------------------------
# .Ch, .Se and .Ss divide chunks of STDIN
{
    local $/ = undef;
    @chunks = split(/^\.(Ch|Se|Ss)$/m, <>);
}
print "I read ", scalar(@chunks), " chunks.\n";
#-----------------------------

# ^^PLEAC^^_6.8
#-----------------------------
while (<>) {
    if (/BEGIN PATTERN/ .. /END PATTERN/) {
        # line falls between BEGIN and END in the
        # text, inclusive.
    }
}

while (<>) {
    if ($FIRST_LINE_NUM .. $LAST_LINE_NUM) {
        # operate only between first and last line, inclusive.
    }
}
#-----------------------------
while (<>) {
    if (/BEGIN PATTERN/ ... /END PATTERN/) {
        # line is between BEGIN and END on different lines
    }
}

while (<>) {
    if ($FIRST_LINE_NUM ... $LAST_LINE_NUM) {
        # operate only between first and last line, but not same
    }
}
#-----------------------------
# command-line to print lines 15 through 17 inclusive (see below)
perl -ne 'print if 15 .. 17' datafile

# print out all <XMP> .. </XMP> displays from HTML doc
while (<>) {
    print if m#<XMP>#i .. m#</XMP>#i;
}
    
# same, but as shell command
# perl -ne 'print if m#<XMP>#i .. m#</XMP>#i' document.html
#-----------------------------
# perl -ne 'BEGIN { $top=3; $bottom=5 }  print if $top .. $bottom' /etc/passwd        # previous command FAILS
# perl -ne 'BEGIN { $top=3; $bottom=5 } \
#     print if $. == $top .. $. ==     $bottom' /etc/passwd    # works
# perl -ne 'print if 3 .. 5' /etc/passwd   # also works
#-----------------------------
print if /begin/ .. /end/;
print if /begin/ ... /end/;
#-----------------------------
while (<>) {
    $in_header =   1  .. /^$/;
    $in_body   = /^$/ .. eof();
}
#-----------------------------
%seen = ();
while (<>) {
    next unless /^From:?\s/i .. /^$/;
    while (/([^<>(),;\s]+\@[^<>(),;\s]+)/g) {
        print "$1\n" unless $seen{$1}++;
    }
}
#-----------------------------

# ^^PLEAC^^_6.9
#-----------------------------
sub glob2pat {
    my $globstr = shift;
    my %patmap = (
	 '*' => '.*',
	 '?' => '.',
	 '[' => '[',
	 ']' => ']',
    );
    $globstr =~ s{(.)} { $patmap{$1} || "\Q$1" }ge;
    return '^' . $globstr . '$'; #'
}
#-----------------------------

# ^^PLEAC^^_6.10
#-----------------------------
while ($line = <>) {
    if ($line =~ /$pattern/o) {
        # do something
    }
}
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/popgrep1
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/popgrep2
#-----------------------------
while (defined($line = <>)) {
     if ($line =~ /\bCO\b/) { print $line; next; }
     if ($line =~ /\bON\b/) { print $line; next; }
     if ($line =~ /\bMI\b/) { print $line; next; }
     if ($line =~ /\bWI\b/) { print $line; next; }
     if ($line =~ /\bMN\b/) { print $line; next; }
}
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/popgrep3
#-----------------------------
sub {
      m/\b$popstates[0]\b/o || m/\b$popstates[1]\b/o ||
      m/\b$popstates[2]\b/o || m/\b$popstates[3]\b/o ||
      m/\b$popstates[4]\b/o
  }
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/grepauth
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/popgrep4
#-----------------------------

# ^^PLEAC^^_6.11
#-----------------------------
do {
    print "Pattern? ";
    chomp($pat = <>);
    eval { "" =~ /$pat/ };
    warn "INVALID PATTERN $@" if $@;
} while $@;
#-----------------------------
sub is_valid_pattern {
    my $pat = shift;
    return eval { "" =~ /$pat/; 1 } || 0;
}
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/paragrep
#-----------------------------
$pat = "You lose @{[ system('rm -rf *')]} big here";
#-----------------------------
$safe_pat = quotemeta($pat);
something() if /$safe_pat/;
#-----------------------------
something() if /\Q$pat/;
#-----------------------------

# ^^PLEAC^^_6.12
#-----------------------------
use locale;
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/localeg
English names: Andreas K Nig

German names:  Andreas König
#-----------------------------

# ^^PLEAC^^_6.13
#-----------------------------
use String::Approx qw(amatch);

if (amatch("PATTERN", @list)) {
    # matched
}

@matches = amatch("PATTERN", @list);
#-----------------------------
use String::Approx qw(amatch);
open(DICT, "/usr/dict/words")               or die "Can't open dict: $!";
while(<DICT>) {
    print if amatch("balast");
}

ballast

balustrade

blast

blastula

sandblast
#-----------------------------

# ^^PLEAC^^_6.14
#-----------------------------
while (/(\d+)/g) {
    print "Found $1\n";
}
#-----------------------------
$n = "   49 here";
$n =~ s/\G /0/g;
print $n;
00049 here
#-----------------------------
while (/\G,?(\d+)/g) {
    print "Found number $1\n";
}
#-----------------------------
$_ = "The year 1752 lost 10 days on the 3rd of September";

while (/(\d+)/gc) {
    print "Found number $1\n";
}

if (/\G(\S+)/g) {
    print "Found $1 after the last number.\n";
}

#Found number 1752
#
#Found number 10
#
#Found number 3
#
#Found rd after the last number.
#-----------------------------
print "The position in \$a is ", pos($a);
pos($a) = 30;
print "The position in \$_ is ", pos;
pos = 30;
#-----------------------------

# ^^PLEAC^^_6.15
#-----------------------------
# greedy pattern
s/<.*>//gs;                     # try to remove tags, very badly

# non-greedy pattern
s/<.*?>//gs;                    # try to remove tags, still rather badly
#-----------------------------
#<b><i>this</i> and <i>that</i> are important</b> Oh, <b><i>me too!</i></b>
#-----------------------------
m{ <b><i>(.*?)</i></b> }sx
#-----------------------------
/BEGIN((?:(?!BEGIN).)*)END/
#-----------------------------
m{ <b><i>(  (?: (?!</b>|</i>). )*  ) </i></b> }sx
#-----------------------------
m{ <b><i>(  (?: (?!</[ib]>). )*  ) </i></b> }sx
#-----------------------------
m{
    <b><i> 
    [^<]*  # stuff not possibly bad, and not possibly the end.
    (?:
 # at this point, we can have '<' if not part of something bad
     (?!  </?[ib]>  )   # what we can't have
     <                  # okay, so match the '<'
     [^<]*              # and continue with more safe stuff
    ) *
    </i></b>
 }sx
#-----------------------------

# ^^PLEAC^^_6.16
#-----------------------------
$/ = '';                      # paragrep mode
while (<>) {
    while ( m{
                \b            # start at a word boundary (begin letters)
                (\S+)         # find chunk of non-whitespace
                \b            # until another word boundary (end letters)
                (
                    \s+       # separated by some whitespace
                    \1        # and that very same chunk again
                    \b        # until another word boundary
                ) +           # one or more sets of those
             }xig
         )
    {
        print "dup word '$1' at paragraph $.\n";
    }
}
#-----------------------------
This is a test
test of the duplicate word finder.
#-----------------------------
$a = 'nobody';
$b = 'bodysnatcher';
if ("$a $b" =~ /^(\w+)(\w+) \2(\w+)$/) {
    print "$2 overlaps in $1-$2-$3\n";
}
body overlaps in no-body-snatcher
#-----------------------------
/^(\w+?)(\w+) \2(\w+)$/, 
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/prime-pattern
#-----------------------------
# solve for 12x + 15y + 16z = 281, maximizing x
if (($X, $Y, $Z)  =
   (('o' x 281)  =~ /^(o*)\1{11}(o*)\2{14}(o*)\3{15}$/))
{
    ($x, $y, $z) = (length($X), length($Y), length($Z));
    print "One solution is: x=$x; y=$y; z=$z.\n";
} else {
    print "No solution.\n";
}
#One solution is: x=17; y=3; z=2.
#-----------------------------
('o' x 281)  =~ /^(o+)\1{11}(o+)\2{14}(o+)\3{15}$/;
#One solution is: x=17; y=3; z=2

('o' x 281)  =~ /^(o*?)\1{11}(o*)\2{14}(o*)\3{15}$/;
#One solution is: x=0; y=7; z=11.

('o' x 281)  =~ /^(o+?)\1{11}(o*)\2{14}(o*)\3{15}$/;
#One solution is: x=1; y=3; z=14.
#-----------------------------

# ^^PLEAC^^_6.17
#-----------------------------
chomp($pattern = <CONFIG_FH>);
if ( $data =~ /$pattern/ ) { ..... }
#-----------------------------
/ALPHA|BETA/;
#-----------------------------
/^(?=.*ALPHA)(?=.*BETA)/s;
#-----------------------------
/ALPHA.*BETA|BETA.*ALPHA/s;
#-----------------------------
/^(?:(?!PAT).)*$/s;
#-----------------------------
/(?=^(?:(?!BAD).)*$)GOOD/s;
#-----------------------------
if (!($string =~ /pattern/)) { something() }   # ugly
if (  $string !~ /pattern/)  { something() }   # preferred
#-----------------------------
if ($string =~ /pat1/ && $string =~ /pat2/ ) { 
something
() }
#-----------------------------
if ($string =~ /pat1/ || $string =~ /pat2/ ) { 
something
() }
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/minigrep
#-----------------------------
 "labelled" =~ /^(?=.*bell)(?=.*lab)/s
#-----------------------------
$string =~ /bell/ && $string =~ /lab/
#-----------------------------
 if ($murray_hill =~ m{
             ^              # start of string
            (?=             # zero-width lookahead
                .*          # any amount of intervening stuff
                bell        # the desired bell string
            )               # rewind, since we were only looking
            (?=             # and do the same thing
                .*          # any amount of intervening stuff
                lab         # and the lab part
            )
         }sx )              # /s means . can match newline
{
    print "Looks like Bell Labs might be in Murray Hill!\n";
}
#-----------------------------
"labelled" =~ /(?:^.*bell.*lab)|(?:^.*lab.*bell)/
#-----------------------------
$brand = "labelled";
if ($brand =~ m{
        (?:                 # non-capturing grouper
            ^ .*?           # any amount of stuff at the front
              bell          # look for a bell
              .*?           # followed by any amount of anything
              lab           # look for a lab
          )                 # end grouper
    |                       # otherwise, try the other direction
        (?:                 # non-capturing grouper
            ^ .*?           # any amount of stuff at the front
              lab           # look for a lab
              .*?           # followed by any amount of anything
              bell          # followed by a bell
          )                 # end grouper
    }sx )                   # /s means . can match newline
{
    print "Our brand has bell and lab separate.\n";
}
#-----------------------------
$map =~ /^(?:(?!waldo).)*$/s
#-----------------------------
if ($map =~ m{
        ^                   # start of string
        (?:                 # non-capturing grouper
            (?!             # look ahead negation
                waldo       # is he ahead of us now?
            )               # is so, the negation failed
            .               # any character (cuzza /s)
        ) *                 # repeat that grouping 0 or more
        $                   # through the end of the string
    }sx )                   # /s means . can match newline
{
    print "There's no waldo here!\n";
}
#-----------------------------
 7:15am  up 206 days, 13:30,  4 users,  load average: 1.04, 1.07, 1.04

USER     TTY      FROM              LOGIN@  IDLE   JCPU   PCPU  WHAT

tchrist  tty1                       5:16pm 36days 24:43   0.03s  xinit

tchrist  tty2                       5:19pm  6days  0.43s  0.43s  -tcsh

tchrist  ttyp0    chthon            7:58am  3days 23.44s  0.44s  -tcsh

gnat     ttyS4    coprolith         2:01pm 13:36m  0.30s  0.30s  -tcsh
#-----------------------------
#% w | minigrep '^(?!.*ttyp).*tchrist'
#-----------------------------
m{
    ^                       # anchored to the start
    (?!                     # zero-width look-ahead assertion
        .*                  # any amount of anything (faster than .*?)
        ttyp                # the string you don't want to find
    )                       # end look-ahead negation; rewind to start
    .*                      # any amount of anything (faster than .*?)
    tchrist                 # now try to find Tom
}x
#-----------------------------
#% w | grep tchrist | grep -v ttyp
#-----------------------------
#% grep -i 'pattern' files
#% minigrep '(?i)pattern' files
#-----------------------------

# ^^PLEAC^^_6.18
#-----------------------------
my $eucjp = q{                 # EUC-JP encoding subcomponents:
    [\x00-\x7F]                # ASCII/JIS-Roman (one-byte/character)
  | \x8E[\xA0-\xDF]            # half-width katakana (two bytes/char)
  | \x8F[\xA1-\xFE][\xA1-\xFE] # JIS X 0212-1990 (three bytes/char)
  | [\xA1-\xFE][\xA1-\xFE]     # JIS X 0208:1997 (two bytes/char)
};
#-----------------------------
/^ (?: $eucjp )*?  \xC5\xEC\xB5\xFE/ox # Trying to find Tokyo
#-----------------------------
/^ (  (?:eucjp)*? ) $Tokyo/$1$Osaka/ox
#-----------------------------
/\G (  (?:eucjp)*? ) $Tokyo/$1$Osaka/gox
#-----------------------------
@chars = /$eucjp/gox; # One character per list element
#-----------------------------
while (<>) {
  my @chars = /$eucjp/gox; # One character per list element
  for my $char (@chars) {
    if (length($char) == 1) {
      # Do something interesting with this one-byte character
    } else {
      # Do something interesting with this multiple-byte character
    }
  }
  my $line = join("",@chars); # Glue list back together
  print $line;
}
#-----------------------------
$is_eucjp = m/^(?:$eucjp)*$/xo;
#-----------------------------
$is_eucjp = m/^(?:$eucjp)*$/xo;
$is_sjis  = m/^(?:$sjis)*$/xo;
#-----------------------------
while (<>) {
  my @chars = /$eucjp/gox; # One character per list element
  for my $euc (@chars) {
    my $uni = $euc2uni{$char};
    if (defined $uni) {
        $euc = $uni;
    } else {
        ## deal with unknown EUC->Unicode mapping here.
    }
  }
  my $line = join("",@chars);
  print $line;
}
#-----------------------------

# ^^PLEAC^^_6.19
#-----------------------------
1 while $addr =~ s/\([^()]*\)//g;
#-----------------------------
Dear someuser@host.com,

Please confirm the mail address you gave us Wed May  6 09:38:41
MDT 1998 by replying to this message.  Include the string
"Rumpelstiltskin" in that reply, but spelled in reverse; that is,
start with "Nik...".  Once this is done, your confirmed address will
be entered into our records.
#-----------------------------

# ^^PLEAC^^_6.20
#-----------------------------
chomp($answer = <>);
if    ("SEND"  =~ /^\Q$answer/i) { print "Action is send\n"  }
elsif ("STOP"  =~ /^\Q$answer/i) { print "Action is stop\n"  }
elsif ("ABORT" =~ /^\Q$answer/i) { print "Action is abort\n" }
elsif ("LIST"  =~ /^\Q$answer/i) { print "Action is list\n"  }
elsif ("EDIT"  =~ /^\Q$answer/i) { print "Action is edit\n"  }
#-----------------------------
use Text::Abbrev;
$href = abbrev qw(send abort list edit);
for (print "Action: "; <>; print "Action: ") {
    chomp;
    my $action = $href->{ lc($_) };
    print "Action is $action\n";
}
#-----------------------------
$name = 'send';
&$name();
#-----------------------------
# assumes that &invoke_editor, &deliver_message,
# $file and $PAGER are defined somewhere else.
use Text::Abbrev;
my($href, %actions, $errors);
%actions = (
    "edit"  => \&invoke_editor,
    "send"  => \&deliver_message,
    "list"  => sub { system($PAGER, $file) },
    "abort" => sub {
                    print "See ya!\n";
                    exit;
               },
    ""      => sub {
                    print "Unknown command: $cmd\n";
                    $errors++;
               },
);

$href = abbrev(keys %actions);

local $_;
for (print "Action: "; <>; print "Action: ") {
    s/^\s+//;       # trim leading  white space
    s/\s+$//;       # trim trailing white space
    next unless $_;
    $actions->{ $href->{ lc($_) } }->();
}
#-----------------------------
$abbreviation = lc($_);
$expansion    = $href->{$abbreviation};
$coderef      = $actions->{$expansion};
&$coderef();
#-----------------------------

# ^^PLEAC^^_6.21
#-----------------------------
#% gunzip -c ~/mail/archive.gz | urlify > archive.urlified
#-----------------------------
#% urlify ~/mail/*.inbox > ~/allmail.urlified
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/urlify
#-----------------------------

# ^^PLEAC^^_6.22
#-----------------------------
#% tcgrep -ril '^From: .*kate' ~/mail
#-----------------------------
# ^^INCLUDE^^ include/perl/ch06/tcgrep
#-----------------------------

# ^^PLEAC^^_6.23
#-----------------------------
m/^m*(d?c{0,3}|c[dm])(l?x{0,3}|x[lc])(v?i{0,3}|i[vx])$/i
#-----------------------------
s/(\S+)(\s+)(\S+)/$3$2$1/
#-----------------------------
m/(\w+)\s*=\s*(.*)\s*$/             # keyword is $1, value is $2
#-----------------------------
m/.{80,}/
#-----------------------------
m|(\d+)/(\d+)/(\d+) (\d+):(\d+):(\d+)|
#-----------------------------
s(/usr/bin)(/usr/local/bin)g
#-----------------------------
s/%([0-9A-Fa-f][0-9A-Fa-f])/chr hex $1/ge
#-----------------------------
s{
    /\*                    # Match the opening delimiter
    .*?                    # Match a minimal number of characters
    \*/                    # Match the closing delimiter
} []gsx;
#-----------------------------
s/^\s+//;
s/\s+$//;
#-----------------------------
s/\\n/\n/g;
#-----------------------------
s/^.*:://
#-----------------------------
m/^([01]?\d\d|2[0-4]\d|25[0-5])\.([01]?\d\d|2[0-4]\d|25[0-5])\.
   ([01]?\d\d|2[0-4]\d|25[0-5])\.([01]?\d\d|2[0-4]\d|25[0-5])$/;
#-----------------------------
s(^.*/)()
#-----------------------------
$cols = ( ($ENV{TERMCAP} || " ") =~ m/:co#(\d+):/ ) ? $1 : 80;
#-----------------------------
($name = " $0 @ARGV") =~ s, /\S+/, ,g;
#-----------------------------
die "This isn't Linux" unless $^O =~ m/linux/i;
#-----------------------------
s/\n\s+/ /g
#-----------------------------
@nums = m/(\d+\.?\d*|\.\d+)/g;
#-----------------------------
@capwords = m/(\b[^\Wa-z0-9_]+\b)/g;
#-----------------------------
@lowords = m/(\b[^\WA-Z0-9_]+\b)/g;
#-----------------------------
@icwords = m/(\b[^\Wa-z0-9_][^\WA-Z0-9_]*\b)/;
#-----------------------------
@links = m/<A[^>]+?HREF\s*=\s*["']?([^'" >]+?)[ '"]?>/sig;   #"'
#-----------------------------
($initial) = m/^\S+\s+(\S)\S*\s+\S/ ? $1 : "";
#-----------------------------
s/"([^"]*)"/``$1''/g   #"
#-----------------------------
{ local $/ = "";
  while (<>) {
    s/\n/ /g;
    s/ {3,}/  /g;
    push @sentences, m/(\S.*?[!?.])(?=  |\Z)/g;
  }
}
#-----------------------------
m/(\d{4})-(\d\d)-(\d\d)/            # YYYY in $1, MM in $2, DD in $3
#-----------------------------
m/ ^
      (?:
       1 \s (?: \d\d\d \s)?            # 1, or 1 and area code
       |                               # ... or ...
       \(\d\d\d\) \s                   # area code with parens
       |                               # ... or ...
       (?: \+\d\d?\d? \s)?             # optional +country code
       \d\d\d ([\s\-])                 # and area code
      )
      \d\d\d (\s|\1)                   # prefix (and area code separator)
      \d\d\d\d                         # exchange
        $
 /x
#-----------------------------
m/\boh\s+my\s+gh?o(d(dess(es)?|s?)|odness|sh)\b/i
#-----------------------------
push(@lines, $1)
    while ($input =~ s/^([^\012\015]*)(\012\015?|\015\012?)//);
#-----------------------------

# ^^PLEAC^^_7.0
#-----------------------------
open(INPUT, "< /usr/local/widgets/data")
    or die "Couldn't open /usr/local/widgets/data for reading: $!\n";

while (<INPUT>) {
    print if /blue/;
}
close(INPUT);
#-----------------------------
$var = *STDIN;
mysub($var, *LOGFILE);
#-----------------------------
use IO::File;

$input = IO::File->new("< /usr/local/widgets/data")
    or die "Couldn't open /usr/local/widgets/data for reading: $!\n";

while (defined($line = $input->getline())) {
    chomp($line);
    STDOUT->print($line) if $line =~ /blue/;
}
$input->close();
#-----------------------------
while (<STDIN>) {                   # reads from STDIN
    unless (/\d/) {
        warn "No digit found.\n";   # writes to STDERR
    }
    print "Read: ", $_;             # writes to STDOUT
}
END { close(STDOUT)                 or die "couldn't close STDOUT: $!" }
#-----------------------------
open(LOGFILE, "> /tmp/log")     or die "Can't write /tmp/log: $!";
#-----------------------------
close(FH)           or die "FH didn't close: $!";
#-----------------------------
$old_fh = select(LOGFILE);                  # switch to LOGFILE for output
print "Countdown initiated ...\n";
select($old_fh);                            # return to original output
print "You have 30 seconds to reach minimum safety distance.\n";
#-----------------------------

# ^^PLEAC^^_7.1
#-----------------------------
open(SOURCE, "< $path")
    or die "Couldn't open $path for reading: $!\n";

open(SINK, "> $path")
    or die "Couldn't open $path for writing: $!\n";
#-----------------------------
use Fcntl;

sysopen(SOURCE, $path, O_RDONLY)
    or die "Couldn't open $path for reading: $!\n";

sysopen(SINK, $path, O_WRONLY)
    or die "Couldn't open $path for writing: $!\n";
#-----------------------------
use IO::File;

# like Perl's open
$fh = IO::File->new("> $filename")
    or die "Couldn't open $filename for writing: $!\n";

# like Perl's sysopen
$fh = IO::File->new($filename, O_WRONLY|O_CREAT)
    or die "Couldn't open $filename for writing: $!\n";

# like stdio's fopen(3)
$fh = IO::File->new($filename, "r+")
    or die "Couldn't open $filename for read and write: $!\n";
#-----------------------------
sysopen(FILEHANDLE, $name, $flags)         or die "Can't open $name : $!";
sysopen(FILEHANDLE, $name, $flags, $perms) or die "Can't open $name : $!";
#-----------------------------
open(FH, "< $path")                                 or die $!;
sysopen(FH, $path, O_RDONLY)                        or die $!;
#-----------------------------
open(FH, "> $path")                                 or die $!;
sysopen(FH, $path, O_WRONLY|O_TRUNC|O_CREAT)        or die $!;
sysopen(FH, $path, O_WRONLY|O_TRUNC|O_CREAT, 0600)  or die $!;
#-----------------------------
sysopen(FH, $path, O_WRONLY|O_EXCL|O_CREAT)         or die $!;
sysopen(FH, $path, O_WRONLY|O_EXCL|O_CREAT, 0600)   or die $!;
#-----------------------------
open(FH, ">> $path")                                or die $!;
sysopen(FH, $path, O_WRONLY|O_APPEND|O_CREAT)       or die $!;
sysopen(FH, $path, O_WRONLY|O_APPEND|O_CREAT, 0600) or die $!;
#-----------------------------
sysopen(FH, $path, O_WRONLY|O_APPEND)               or die $!;
#-----------------------------
open(FH, "+< $path")                                or die $!;
sysopen(FH, $path, O_RDWR)                          or die $!;
#-----------------------------
sysopen(FH, $path, O_RDWR|O_CREAT)                  or die $!;
sysopen(FH, $path, O_RDWR|O_CREAT, 0600)            or die $!;
#-----------------------------
sysopen(FH, $path, O_RDWR|O_EXCL|O_CREAT)           or die $!;
sysopen(FH, $path, O_RDWR|O_EXCL|O_CREAT, 0600)     or die $!;
#-----------------------------

# ^^PLEAC^^_7.2
#-----------------------------
$filename =~ s#^(\s)#./$1#;
open(HANDLE, "< $filename\0")          or die "cannot open $filename : $!\n";
#-----------------------------
sysopen(HANDLE, $filename, O_RDONLY)   or die "cannot open $filename: $!\n";
#-----------------------------
$filename = shift @ARGV;
open(INPUT, $filename)               or die "Couldn't open $filename : $!\n";
#-----------------------------
open(OUTPUT, ">$filename")
    or die "Couldn't open $filename for writing: $!\n";
#-----------------------------
use Fcntl;                          # for file constants

sysopen(OUTPUT, $filename, O_WRONLY|O_TRUNC)
    or die "Can't open $filename for writing: $!\n";
#-----------------------------
$file =~ s#^(\s)#./$1#;
open(OUTPUT, "> $file\0")
        or die "Couldn't open $file for OUTPUT : $!\n";
#-----------------------------

# ^^PLEAC^^_7.3
#-----------------------------
$filename =~ s{ ^ ~ ( [^/]* ) }
              { $1
                    ? (getpwnam($1))[7]
                    : ( $ENV{HOME} || $ENV{LOGDIR}
                         || (getpwuid($>))[7]
                       )
}ex;
#-----------------------------
#    ~user
#    ~user/blah
#    ~
#    ~/blah
#-----------------------------

# ^^PLEAC^^_7.4
#-----------------------------
open($path, "< $path")
    or die "Couldn't open $path for reading : $!\n";
#-----------------------------
#Argument "3\n" isn't numeric in multiply at tallyweb line 16, <LOG> chunk 17.
#-----------------------------
#Argument "3\n" isn't numeric in multiply at tallyweb
#
#    line 16, </usr/local/data/mylog3.dat> chunk 17.
#-----------------------------

# ^^PLEAC^^_7.5
#-----------------------------
use IO::File;

$fh = IO::File->new_tmpfile
        or die "Unable to make new temporary file: $!";
#-----------------------------
use IO::File;
use POSIX qw(tmpnam);

# try new temporary filenames until we get one that didn't already exist
do { $name = tmpnam() }
    until $fh = IO::File->new($name, O_RDWR|O_CREAT|O_EXCL);

# install atexit-style handler so that when we exit or die,
# we automatically delete this temporary file
END { unlink($name) or die "Couldn't unlink $name : $!" }

# now go on to use the file ...
#-----------------------------
for (;;) {
    $name = tmpnam();
    sysopen(TMP, $tmpnam, O_RDWR | O_CREAT | O_EXCL) && last;
}
unlink $tmpnam;
#-----------------------------
use IO::File;

$fh = IO::File->new_tmpfile             or die "IO::File->new_tmpfile: $!";
$fh->autoflush(1);
print $fh "$i\n" while $i++ < 10;
seek($fh, 0, 0)                         or die "seek: $!";
print "Tmp file has: ", <$fh>;
#-----------------------------

# ^^PLEAC^^_7.6
#-----------------------------
while (<DATA>) {
    # process the line
}
#__DATA__
# your data goes here
#-----------------------------
while (<main::DATA>) {
    # process the line
}
#__END__
# your data goes here
#-----------------------------
use POSIX qw(strftime);

$raw_time = (stat(DATA))[9];
$size     = -s DATA;
$kilosize = int($size / 1024) . 'k';

print "<P>Script size is $kilosize\n";
print strftime("<P>Last script update: %c (%Z)\n", localtime($raw_time));

#__DATA__
#DO NOT REMOVE THE PRECEDING LINE.
#Everything else in this file will be ignored.
#-----------------------------

# ^^PLEAC^^_7.7
#-----------------------------
while (<>) {
    # do something with the line
}
#-----------------------------
while (<>) {
    # ...
 }
#-----------------------------
unshift(@ARGV, '-') unless @ARGV;
while ($ARGV = shift @ARGV) {
    unless (open(ARGV, $ARGV)) {
        warn "Can't open $ARGV: $!\n";
        next;
    }
    while (defined($_ = <ARGV>)) {
        # ...
    }
}
#-----------------------------
@ARGV = glob("*.[Cch]") unless @ARGV;
#-----------------------------
# arg demo 1: Process optional -c flag 
if (@ARGV && $ARGV[0] eq '-c') { 
    $chop_first++;
    shift;
}

# arg demo 2: Process optional -NUMBER flag    
if (@ARGV && $ARGV[0] =~ /^-(\d+)$/) { 
    $columns = $1; 
    shift;
}

# arg demo 3: Process clustering -a, -i, -n, or -u flags     
while (@ARGV && $ARGV[0] =~ /^-(.+)/ && (shift, ($_ = $1), 1)) { 
    next if /^$/; 
    s/a// && (++$append,      redo);
    s/i// && (++$ignore_ints, redo); 
    s/n// && (++$nostdout,    redo); 
    s/u// && (++$unbuffer,    redo); 
    die "usage: $0 [-ainu] [filenames] ...\n";    
}
#-----------------------------
undef $/;		     
while (<>) { 	
    # $_ now has the complete contents of 	
    # the file whose name is in $ARGV     
}
#-----------------------------
{     # create block for local 	
    local $/;         # record separator now undef 	
    while (<>) { 	    
        # do something; called functions still have 	    
        # undeffed version of $/ 	
    }     
}                     # $/ restored here
#-----------------------------
while (<>) { 	
    print "$ARGV:$.:$_"; 	
    close ARGV if eof;     
}
#-----------------------------
# ^^INCLUDE^^ include/perl/ch07/findlogin1
#-----------------------------
# ^^INCLUDE^^ include/perl/ch07/findlogin2
#-----------------------------
#% perl -ne 'print if /login/'
#-----------------------------
# ^^INCLUDE^^ include/perl/ch07/lowercase1
#-----------------------------
# ^^INCLUDE^^ include/perl/ch07/lowercase2
#-----------------------------
#% perl -Mlocale -pe 's/([^\W0-9_])/\l$1/g'
#-----------------------------
# ^^INCLUDE^^ include/perl/ch07/countchunks
#-----------------------------
#+0894382237
#less /etc/motd
#+0894382239
#vi ~/.exrc
#+0894382242
#date
#+0894382242
#who
#+0894382288
#telnet home
#-----------------------------
#% perl -pe 's/^#\+(\d+)\n/localtime($1) . " "/e' 
#Tue May  5 09:30:37 1998     less /etc/motd 
#
#Tue May  5 09:30:39 1998     vi ~/.exrc 
#
#Tue May  5 09:30:42 1998     date
#
#Tue May  5 09:30:42 1998     who 
#
#Tue May  5 09:31:28 1998     telnet home
#-----------------------------

# ^^PLEAC^^_7.8
#-----------------------------
open(OLD, "< $old")         or die "can't open $old: $!";
open(NEW, "> $new")         or die "can't open $new: $!";
while (<OLD>) {
    # change $_, then...
    print NEW $_            or die "can't write $new: $!";
}
close(OLD)                  or die "can't close $old: $!";
close(NEW)                  or die "can't close $new: $!";
rename($old, "$old.orig")   or die "can't rename $old to $old.orig: $!";
rename($new, $old)          or die "can't rename $new to $old: $!";
#-----------------------------
while (<OLD>) {
    if ($. == 20) {
        print NEW "Extra line 1\n";
        print NEW "Extra line 2\n";
    }
    print NEW $_;
}
#-----------------------------
while (<OLD>) {
    next if 20 .. 30;
    print NEW $_;
}
#-----------------------------

# ^^PLEAC^^_7.9
#-----------------------------
#% perl -i.orig -p -e 'FILTER COMMAND' file1 file2 file3 ...
#-----------------------------
#!/usr/bin/perl -i.orig -p
# filter commands go here
#-----------------------------
#% perl -pi.orig -e 's/DATE/localtime/e'
#-----------------------------
while (<>) {
    if ($ARGV ne $oldargv) {           # are we at the next file?
        rename($ARGV, $ARGV . '.orig');
        open(ARGVOUT, ">$ARGV");       # plus error check
        select(ARGVOUT);
        $oldargv = $ARGV;
    }
    s/DATE/localtime/e;
}
continue{
    print;
}
select (STDOUT);                      # restore default output
#-----------------------------
#Dear Sir/Madam/Ravenous Beast,
#    As of DATE, our records show your account
#is overdue.  Please settle by the end of the month.
#Yours in cheerful usury,
#    --A. Moneylender
#-----------------------------
#Dear Sir/Madam/Ravenous Beast,
#    As of Sat Apr 25 12:28:33 1998, our records show your account
#is overdue.  Please settle by the end of the month.
#Yours in cheerful usury,
#    --A. Moneylender
#-----------------------------
#% perl -i.old -pe 's{\bhisvar\b}{hervar}g' *.[Cchy]
#-----------------------------
# set up to iterate over the *.c files in the current directory,
# editing in place and saving the old file with a .orig extension
local $^I   = '.orig';              # emulate  -i.orig
local @ARGV = glob("*.c");          # initialize list of files
while (<>) {
    if ($. == 1) {
        print "This line should appear at the top of each file\n";
    }
    s/\b(p)earl\b/${1}erl/ig;       # Correct typos, preserving case
    print;
} continue {close ARGV if eof} 
#-----------------------------

# ^^PLEAC^^_7.10
#-----------------------------
open(FH, "+< FILE")                 or die "Opening: $!";
@ARRAY = <FH>;
# change ARRAY here
seek(FH,0,0)                        or die "Seeking: $!";
print FH @ARRAY                     or die "Printing: $!";
truncate(FH,tell(FH))               or die "Truncating: $!";
close(FH)                           or die "Closing: $!";
#-----------------------------
open(F, "+< $infile")       or die "can't read $infile: $!";
$out = '';
while (<F>) {
    s/DATE/localtime/eg;
    $out .= $_;
}
seek(F, 0, 0)               or die "can't seek to start of $infile: $!";
print F $out                or die "can't print to $infile: $!";
truncate(F, tell(F))        or die "can't truncate $infile: $!";
close(F)                    or die "can't close $infile: $!";
#-----------------------------

# ^^PLEAC^^_7.11
#-----------------------------
open(FH, "+< $path")                or die "can't open $path: $!";
flock(FH, 2)                        or die "can't flock $path: $!";
# update file, then...
close(FH)                           or die "can't close $path: $!";
#-----------------------------
sub LOCK_SH()  { 1 }     #  Shared lock (for reading)
sub LOCK_EX()  { 2 }     #  Exclusive lock (for writing)
sub LOCK_NB()  { 4 }     #  Non-blocking request (don't stall)
sub LOCK_UN()  { 8 }     #  Free the lock (careful!)
#-----------------------------
unless (flock(FH, LOCK_EX|LOCK_NB)) {
    warn "can't immediately write-lock the file ($!), blocking ...";
    unless (flock(FH, LOCK_EX)) {
        die "can't get write-lock on numfile: $!";
    }
}
#-----------------------------
if ($] < 5.004) {                   # test Perl version number
     my $old_fh = select(FH);
     local $| = 1;                  # enable command buffering
     local $\ = '';                 # clear output record separator
     print "";                      # trigger output flush
     select($old_fh);               # restore previous filehandle
}
flock(FH, LOCK_UN);
#-----------------------------
use Fcntl qw(:DEFAULT :flock);

sysopen(FH, "numfile", O_RDWR|O_CREAT)
                                    or die "can't open numfile: $!";
flock(FH, LOCK_EX)                  or die "can't write-lock numfile: $!";
# Now we have acquired the lock, it's safe for I/O
$num = <FH> || 0;                   # DO NOT USE "or" THERE!!
seek(FH, 0, 0)                      or die "can't rewind numfile : $!";
truncate(FH, 0)                     or die "can't truncate numfile: $!";
print FH $num+1, "\n"               or die "can't write numfile: $!";
close(FH)                           or die "can't close numfile: $!";
#-----------------------------

# ^^PLEAC^^_7.12
#-----------------------------
$old_fh = select(OUTPUT_HANDLE);
$| = 1;
select($old_fh);
#-----------------------------
use IO::Handle;
OUTPUT_HANDLE->autoflush(1);
#-----------------------------
# ^^INCLUDE^^ include/perl/ch07/seeme
#-----------------------------
    select((select(OUTPUT_HANDLE), $| = 1)[0]);
#-----------------------------
use FileHandle;

STDERR->autoflush;          # already unbuffered in stdio
$filehandle->autoflush(0);
#-----------------------------
use IO::Handle;
# assume REMOTE_CONN is an interactive socket handle,
# but DISK_FILE is a handle to a regular file.
autoflush REMOTE_CONN  1;           # unbuffer for clarity
autoflush DISK_FILE    0;           # buffer this for speed
#-----------------------------
# ^^INCLUDE^^ include/perl/ch07/getpcomidx
#-----------------------------

# ^^PLEAC^^_7.13
#-----------------------------
$rin = '';
# repeat next line for all filehandles to poll
vec($rin, fileno(FH1), 1) = 1;
vec($rin, fileno(FH2), 1) = 1;
vec($rin, fileno(FH3), 1) = 1;

$nfound = select($rout=$rin, undef, undef, 0);
if ($nfound) {
  # input waiting on one or more of those 3 filehandles
  if (vec($rout,fileno(FH1),1)) { 
      # do something with FH1
  }
  if (vec($rout,fileno(FH2),1)) {
      # do something with FH2
  }
  if (vec($rout,fileno(FH3),1)) {
      # do something with FH3
  }
}
#-----------------------------
use IO::Select;

$select = IO::Select->new();
# repeat next line for all filehandles to poll
$select->add(*FILEHANDLE);
if (@ready = $select->can_read(0)) {
    # input waiting on the filehandles in @ready
}
#-----------------------------
$rin = '';
vec($rin, fileno(FILEHANDLE), 1) = 1;
$nfound = select($rin, undef, undef, 0);    # just check
if ($nfound) {
    $line = <FILEHANDLE>;
    print "I read $line";
}
#-----------------------------

# ^^PLEAC^^_7.14
#-----------------------------
use Fcntl;

sysopen(MODEM, "/dev/cua0", O_NONBLOCK|O_RDWR)
    or die "Can't open modem: $!\n";
#-----------------------------
use Fcntl;

$flags = '';
fcntl(HANDLE, F_GETFL, $flags)
    or die "Couldn't get flags for HANDLE : $!\n";
$flags |= O_NONBLOCK;
fcntl(HANDLE, F_SETFL, $flags)
    or die "Couldn't set flags for HANDLE: $!\n";
#-----------------------------
use POSIX qw(:errno_h);

$rv = syswrite(HANDLE, $buffer, length $buffer);
if (!defined($rv) && $! == EAGAIN) {
    # would block
} elsif ($rv != length $buffer) {
    # incomplete write
} else {
    # successfully wrote
}

$rv = sysread(HANDLE, $buffer, $BUFSIZ);
if (!defined($rv) && $! == EAGAIN) {
    # would block
} else {
    # successfully read $rv bytes from HANDLE
}
#-----------------------------

# ^^PLEAC^^_7.15
#-----------------------------
$size = pack("L", 0);
ioctl(FH, $FIONREAD, $size)     or die "Couldn't call ioctl: $!\n";
$size = unpack("L", $size);

# $size bytes can be read
#-----------------------------
require 'sys/ioctl.ph';

$size = pack("L", 0);
ioctl(FH, FIONREAD(), $size)    or die "Couldn't call ioctl: $!\n";
$size = unpack("L", $size);
#-----------------------------
#% grep FIONREAD /usr/include/*/*
#/usr/include/asm/ioctls.h:#define FIONREAD      0x541B
#-----------------------------
#% cat > fionread.c
##include <sys/ioctl.h>
#main() {
#
#    printf("%#08x\n", FIONREAD);
#}
#^D
#% cc -o fionread fionread
#% ./fionread
#0x4004667f
#-----------------------------
$FIONREAD = 0x4004667f;         # XXX: opsys dependent

$size = pack("L", 0);
ioctl(FH, $FIONREAD, $size)     or die "Couldn't call ioctl: $!\n";
$size = unpack("L", $size);
#-----------------------------

# ^^PLEAC^^_7.16
#-----------------------------
$variable = *FILEHANDLE;        # save in variable
subroutine(*FILEHANDLE);        # or pass directly

sub subroutine {
    my $fh = shift;
    print $fh "Hello, filehandle!\n";
}
#-----------------------------
use FileHandle;                   # make anon filehandle
$fh = FileHandle->new();

use IO::File;                     # 5.004 or higher
$fh = IO::File->new();
#-----------------------------
$fh_a = IO::File->new("< /etc/motd")    or die "open /etc/motd: $!";
$fh_b = *STDIN;
some_sub($fh_a, $fh_b);
#-----------------------------
sub return_fh {             # make anon filehandle
    local *FH;              # must be local, not my
    # now open it if you want to, then...
    return *FH;
}

$handle = return_fh();
#-----------------------------
sub accept_fh {
    my $fh = shift;
    print $fh "Sending to indirect filehandle\n";
}
#-----------------------------
sub accept_fh {
    local *FH = shift;
    print  FH "Sending to localized filehandle\n";
}
#-----------------------------
accept_fh(*STDOUT);
accept_fh($handle);
#-----------------------------
@fd = (*STDIN, *STDOUT, *STDERR);
print $fd[1] "Type it: ";                           # WRONG
$got = <$fd[0]>                                     # WRONG
print $fd[2] "What was that: $got";                 # WRONG
#-----------------------------
print  { $fd[1] } "funny stuff\n";
printf { $fd[1] } "Pity the poor %x.\n", 3_735_928_559;
Pity the poor deadbeef.
#-----------------------------
$ok = -x "/bin/cat";                
print { $ok ? $fd[1] : $fd[2] } "cat stat $ok\n";
print { $fd[ 1 + ($ok || 0) ]  } "cat stat $ok\n";           
#-----------------------------
$got = readline($fd[0]);
#-----------------------------

# ^^PLEAC^^_7.17
#-----------------------------
use FileCache;
cacheout ($path);         # each time you use a filehandle
print $path "output";
#-----------------------------
# ^^INCLUDE^^ include/perl/ch07/splitwulog
#-----------------------------

# ^^PLEAC^^_7.18
#-----------------------------
foreach $filehandle (@FILEHANDLES) {
    print $filehandle $stuff_to_print;
}
#-----------------------------
open(MANY, "| tee file1 file2 file3 > /dev/null")   or die $!;
print MANY "data\n"                                 or die $!;
close(MANY)                                         or die $!;
#-----------------------------
# `use strict' complains about this one:
for $fh ('FH1', 'FH2', 'FH3')   { print $fh "whatever\n" }
# but not this one:
for $fh (*FH1, *FH2, *FH3)      { print $fh "whatever\n" }
#-----------------------------
open (FH, "| tee file1 file2 file3 >/dev/null");
print FH "whatever\n";
#-----------------------------
# make STDOUT go to three files, plus original STDOUT
open (STDOUT, "| tee file1 file2 file3") or die "Teeing off: $!\n";
print "whatever\n"                       or die "Writing: $!\n";
close(STDOUT)                            or die "Closing: $!\n";
#-----------------------------

# ^^PLEAC^^_7.19
#-----------------------------
open(FH, "<&=$FDNUM");      # open FH to the descriptor itself
open(FH, "<&$FDNUM");       # open FH to a copy of the descriptor

use IO::Handle;

$fh->fdopen($FDNUM, "r");   # open file descriptor 3 for reading
#-----------------------------
use IO::Handle;
$fh = IO::Handle->new();

$fh->fdopen(3, "r");            # open fd 3 for reading
#-----------------------------
$fd = $ENV{MHCONTEXTFD};
open(MHCONTEXT, "<&=$fd")   or die "couldn't fdopen $fd: $!";
# after processing
close(MHCONTEXT)            or die "couldn't close context file: $!";
#-----------------------------

# ^^PLEAC^^_7.20
#-----------------------------
*ALIAS = *ORIGINAL;
#-----------------------------
open(OUTCOPY, ">&STDOUT")   or die "Couldn't dup STDOUT: $!";
open(INCOPY,  "<&STDIN" )   or die "Couldn't dup STDIN : $!";
#-----------------------------
open(OUTALIAS, ">&=STDOUT") or die "Couldn't alias STDOUT: $!";
open(INALIAS,  "<&=STDIN")  or die "Couldn't alias STDIN : $!";
open(BYNUMBER, ">&=5")      or die "Couldn't alias file descriptor 5: $!";
#-----------------------------
# take copies of the file descriptors
open(OLDOUT, ">&STDOUT");
open(OLDERR, ">&STDERR");

# redirect stdout and stderr
open(STDOUT, "> /tmp/program.out")  or die "Can't redirect stdout: $!";
open(STDERR, ">&STDOUT")            or die "Can't dup stdout: $!";

# run the program
system($joe_random_program);

# close the redirected filehandles
close(STDOUT)                       or die "Can't close STDOUT: $!";
close(STDERR)                       or die "Can't close STDERR: $!";

# restore stdout and stderr
open(STDERR, ">&OLDERR")            or die "Can't restore stderr: $!";
open(STDOUT, ">&OLDOUT")            or die "Can't restore stdout: $!";

# avoid leaks by closing the independent copies
close(OLDOUT)                       or die "Can't close OLDOUT: $!";
close(OLDERR)                       or die "Can't close OLDERR: $!";
#-----------------------------

# ^^PLEAC^^_7.21
#-----------------------------
# ^^INCLUDE^^ include/perl/ch07/drivelock
#-----------------------------
package File::LockDir;
# module to provide very basic filename-level
# locks.  No fancy systems calls.  In theory,
# directory info is sync'd over NFS.  Not
# stress tested.

use strict;

use Exporter;
use vars qw(@ISA @EXPORT);
@ISA      = qw(Exporter);
@EXPORT   = qw(nflock nunflock);

use vars qw($Debug $Check);
$Debug  ||= 0;  # may be predefined
$Check  ||= 5;  # may be predefined

use Cwd;
use Fcntl;
use Sys::Hostname;
use File::Basename;
use File::stat;
use Carp;

my %Locked_Files = ();

# usage: nflock(FILE; NAPTILL)
sub nflock($;$) {
    my $pathname = shift;
    my $naptime  = shift || 0;
    my $lockname = name2lock($pathname);
    my $whosegot = "$lockname/owner";
    my $start    = time();
    my $missed   = 0;
    local *OWNER;

    # if locking what I've already locked, return
    if ($Locked_Files{$pathname}) {
        carp "$pathname already locked";
        return 1
    }

    if (!-w dirname($pathname)) {
        croak "can't write to directory of $pathname";
    }

    while (1) {
        last if mkdir($lockname, 0777);
        confess "can't get $lockname: $!" if $missed++ > 10
                        && !-d $lockname;
        if ($Debug) {{
            open(OWNER, "< $whosegot") || last; # exit "if"!
            my $lockee = <OWNER>;
            chomp($lockee);
            printf STDERR "%s $0\[$$]: lock on %s held by %s\n",
                scalar(localtime), $pathname, $lockee;
            close OWNER;
        }}
        sleep $Check;
        return if $naptime && time > $start+$naptime;
    }
    sysopen(OWNER, $whosegot, O_WRONLY|O_CREAT|O_EXCL)
                            or croak "can't create $whosegot: $!";
    printf OWNER "$0\[$$] on %s since %s\n",
            hostname(), scalar(localtime);
    close(OWNER)                
        or croak "close $whosegot: $!";
    $Locked_Files{$pathname}++;
    return 1;
}

# free the locked file
sub nunflock($) {
    my $pathname = shift;
    my $lockname = name2lock($pathname);
    my $whosegot = "$lockname/owner";
    unlink($whosegot);
    carp "releasing lock on $lockname" if $Debug;
    delete $Locked_Files{$pathname};
    return rmdir($lockname);
}

# helper function
sub name2lock($) {
    my $pathname = shift;
    my $dir  = dirname($pathname);
    my $file = basename($pathname);
    $dir = getcwd() if $dir eq '.';
    my $lockname = "$dir/$file.LOCKDIR";
    return $lockname;
}

# anything forgotten?
END {
    for my $pathname (keys %Locked_Files) {
        my $lockname = name2lock($pathname);
        my $whosegot = "$lockname/owner";
        carp "releasing forgotten $lockname";
        unlink($whosegot);
        return rmdir($lockname);
    }
}

1;
#-----------------------------

# ^^PLEAC^^_7.22
#-----------------------------
4: 18584 was just here
#-----------------------------
29: 24652 ZAPPED 24656
#-----------------------------
#% lockarea 5 &
#% rep -1 'cat /tmp/lkscreen'
#-----------------------------
# ^^INCLUDE^^ include/perl/ch07/lockarea
#-----------------------------

# ^^PLEAC^^_8.0
#-----------------------------
while (defined ($line = <DATAFILE>)) {
    chomp $line;
    $size = length $line;
    print "$size\n";                # output size of line
}
#-----------------------------
while (<DATAFILE>) {
    chomp;
    print length, "\n";             # output size of line
}
#-----------------------------
@lines = <DATAFILE>;
#-----------------------------
undef $/;
$whole_file = <FILE>;               # 'slurp' mode
#-----------------------------
#% perl -040 -e '$word = <>; print "First word is $word\n";'
#-----------------------------
#% perl -ne 'BEGIN { $/="%%\n" } chomp; print if /Unix/i' fortune.dat
#-----------------------------
print HANDLE "One", "two", "three"; # "Onetwothree"
print "Baa baa black sheep.\n";     # Sent to default output handle
#-----------------------------
$rv = read(HANDLE, $buffer, 4096)
        or die "Couldn't read from HANDLE : $!\n";
# $rv is the number of bytes read,
# $buffer holds the data read
#-----------------------------
truncate(HANDLE, $length)
    or die "Couldn't truncate: $!\n";
truncate("/tmp/$$.pid", $length)
    or die "Couldn't truncate: $!\n";
#-----------------------------
$pos = tell(DATAFILE);
print "I'm $pos bytes from the start of DATAFILE.\n";
#-----------------------------
seek(LOGFILE, 0, 2)         or die "Couldn't seek to the end: $!\n";
seek(DATAFILE, $pos, 0)     or die "Couldn't seek to $pos: $!\n";
seek(OUT, -20, 1)           or die "Couldn't seek back 20 bytes: $!\n";
#-----------------------------
$written = syswrite(DATAFILE, $mystring, length($mystring));
die "syswrite failed: $!\n" unless $written == length($mystring);
$read = sysread(INFILE, $block, 256, 5);
warn "only read $read bytes, not 256" if 256 != $read;
#-----------------------------
$pos = sysseek(HANDLE, 0, 1);       # don't change position
die "Couldn't sysseek: $!\n" unless defined $pos;
#-----------------------------

# ^^PLEAC^^_8.1
#-----------------------------
while (defined($line = <FH>) ) {
    chomp $line;
    if ($line =~ s/\\$//) {
        $line .= <FH>;
        redo unless eof(FH);
    }
    # process full record in $line here
}
#-----------------------------
# DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) \
#         $(TEXINFOS) $(INFOS) $(MANS) $(DATA)
# DEP_DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) \
#         $(TEXINFOS) $(INFO_DEPS) $(MANS) $(DATA) \
#         $(EXTRA_DIST)
#-----------------------------
if ($line =~ s/\\\s*$//) { 
    # as before
}
#-----------------------------

# ^^PLEAC^^_8.2
#-----------------------------
$count = `wc -l < $file`;
die "wc failed: $?" if $?;
chomp($count);
#-----------------------------
open(FILE, "< $file") or die "can't open $file: $!";
$count++ while <FILE>;
# $count now holds the number of lines read
#-----------------------------
$count += tr/\n/\n/ while sysread(FILE, $_, 2 ** 16);
#-----------------------------
open(FILE, "< $file") or die "can't open $file: $!";
$count++ while <FILE>;
# $count now holds the number of lines read
#-----------------------------
open(FILE, "< $file") or die "can't open $file: $!";
for ($count=0; <FILE>; $count++) { }
#-----------------------------
1 while <FILE>;
$count = $.;
#-----------------------------
$/ = '';            # enable paragraph mode for all reads
open(FILE, $file) or die "can't open $file: $!";
1 while <FILE>;
$para_count = $.;
#-----------------------------

# ^^PLEAC^^_8.3
#-----------------------------
while (<>) {
    for $chunk (split) {
        # do something with $chunk
    }
}
#-----------------------------
while (<>) {
    while ( /(\w[\w'-]*)/g ) {  #'
        # do something with $1
    }
}
#-----------------------------
# Make a word frequency count
%seen = ();
while (<>) {
    while ( /(\w['\w-]*)/g ) {  #'
        $seen{lc $1}++;
    }
}

# output hash in a descending numeric sort of its values
foreach $word ( sort { $seen{$b} <=> $seen{$a} } keys %seen) {
    printf "%5d %s\n", $seen{$word}, $word;
}
#-----------------------------
# Line frequency count
%seen = ();
while (<>) {
    $seen{lc $_}++;
}
foreach $line ( sort { $seen{$b} <=> $seen{$a} } keys %seen ) {
    printf "%5d %s", $seen{$line}, $line;
}
#-----------------------------

# ^^PLEAC^^_8.4
#-----------------------------
@lines = <FILE>;
while ($line = pop @lines) {
    # do something with $line
}
#-----------------------------
@lines = reverse <FILE>;
foreach $line (@lines) {
    # do something with $line
}
#-----------------------------
for ($i = $#lines; $i != -1; $i--) {
    $line = $lines[$i];
}
#-----------------------------
# this enclosing block keeps local $/ temporary
{           
    local $/ = '';
    @paragraphs = reverse <FILE>;
}

foreach $paragraph (@paragraphs) {
    # do something
}
#-----------------------------

# ^^PLEAC^^_8.5
#-----------------------------
for (;;) {
    while (<FH>) { .... }
    sleep $SOMETIME;
    seek(FH, 0, 1);
}
#-----------------------------
use IO::Seekable;

for (;;) {
    while (<FH>) { .... }
    sleep $SOMETIME;
    FH->clearerr();
}
#-----------------------------
$naptime = 1;

use IO::Handle;
open (LOGFILE, "/tmp/logfile") or die "can't open /tmp/logfile: $!";
for (;;) {
    while (<LOGFILE>) { print }     # or appropriate processing
    sleep $naptime;
    LOGFILE->clearerr();            # clear stdio error flag
}
#-----------------------------
for (;;) {
    for ($curpos = tell(LOGFILE); <LOGFILE>; $curpos = tell(LOGFILE)) {
        # process $_ here
    }
    sleep $naptime;
    seek(LOGFILE, $curpos, 0);  # seek to where we had been
}
#-----------------------------
exit if (stat(LOGFILE))[3] == 0
#-----------------------------
use File::stat;
exit if stat(*LOGFILE)->nlink == 0;
#-----------------------------

# ^^PLEAC^^_8.6
#-----------------------------
srand;
rand($.) < 1 && ($line = $_) while <>;
# $line is the random line
#-----------------------------
$/ = "%%\n";
@ARGV = qw( /usr/share/games/fortunes );
srand;
rand($.) < 1 && ($adage = $_) while <>;
print $adage;
#-----------------------------

# ^^PLEAC^^_8.7
#-----------------------------
# assumes the &shuffle sub from Chapter 4
while (<INPUT>) {
    push(@lines, $_);
}
@reordered = shuffle(@lines);
foreach (@reordered) {
    print OUTPUT $_;
}
#-----------------------------

# ^^PLEAC^^_8.8
#-----------------------------
# looking for line number $DESIRED_LINE_NUMBER
$. = 0;
do { $LINE = <HANDLE> } until $. == $DESIRED_LINE_NUMBER || eof;
#-----------------------------
@lines = <HANDLE>;
$LINE = $lines[$DESIRED_LINE_NUMBER];
#-----------------------------
# usage: build_index(*DATA_HANDLE, *INDEX_HANDLE)
sub build_index {
    my $data_file  = shift;
    my $index_file = shift;
    my $offset     = 0;

    while (<$data_file>) {
        print $index_file pack("N", $offset);
        $offset = tell($data_file);
    }
}

# usage: line_with_index(*DATA_HANDLE, *INDEX_HANDLE, $LINE_NUMBER)
# returns line or undef if LINE_NUMBER was out of range
sub line_with_index {
    my $data_file   = shift;
    my $index_file  = shift;
    my $line_number = shift;

    my $size;               # size of an index entry
    my $i_offset;           # offset into the index of the entry
    my $entry;              # index entry
    my $d_offset;           # offset into the data file

    $size = length(pack("N", 0));
    $i_offset = $size * ($line_number-1);
    seek($index_file, $i_offset, 0) or return;
    read($index_file, $entry, $size);
    $d_offset = unpack("N", $entry);
    seek($data_file, $d_offset, 0);
    return scalar(<$data_file>);
}

# usage:
open(FILE, "< $file")         or die "Can't open $file for reading: $!\n";
open(INDEX, "+>$file.idx")
        or die "Can't open $file.idx for read/write: $!\n";
build_index(*FILE, *INDEX);
$line = line_with_index(*FILE, *INDEX, $seeking);
#-----------------------------
use DB_File;
use Fcntl;

$tie = tie(@lines, $FILE, "DB_File", O_RDWR, 0666, $DB_RECNO) or die 
    "Cannot open file $FILE: $!\n";
# extract it
$line = $lines[$sought - 1];
#-----------------------------
# ^^INCLUDE^^ include/perl/ch08/print_line-v1
#-----------------------------
# ^^INCLUDE^^ include/perl/ch08/print_line-v2
#-----------------------------
# ^^INCLUDE^^ include/perl/ch08/print_line-v3
#-----------------------------

# ^^PLEAC^^_8.9
#-----------------------------
# given $RECORD with field separated by PATTERN,
# extract @FIELDS.
@FIELDS = split(/PATTERN/, $RECORD);
#-----------------------------
split(/([+-])/, "3+5-2");
#-----------------------------
(3, '+', 5, '-', 2)
#-----------------------------
@fields = split(/:/, $RECORD);
#-----------------------------
@fields = split(/\s+/, $RECORD);
#-----------------------------
@fields = split(" ", $RECORD);
#-----------------------------

# ^^PLEAC^^_8.10
#-----------------------------
open (FH, "+< $file")               or die "can't update $file: $!";
while ( <FH> ) {
    $addr = tell(FH) unless eof(FH);
}
truncate(FH, $addr)                 or die "can't truncate $file: $!";
#-----------------------------

# ^^PLEAC^^_8.11
#-----------------------------
binmode(HANDLE);
#-----------------------------
$gifname = "picture.gif";
open(GIF, $gifname)         or die "can't open $gifname: $!";

binmode(GIF);               # now DOS won't mangle binary input from GIF
binmode(STDOUT);            # now DOS won't mangle binary output to STDOUT

while (read(GIF, $buff, 8 * 2**10)) {
    print STDOUT $buff;
}
#-----------------------------

# ^^PLEAC^^_8.12
#-----------------------------
$ADDRESS = $RECSIZE * $RECNO;
seek(FH, $ADDRESS, 0) or die "seek:$!";
read(FH, $BUFFER, $RECSIZE);
#-----------------------------
$ADDRESS = $RECSIZE * ($RECNO-1);
#-----------------------------

# ^^PLEAC^^_8.13
#-----------------------------
use Fcntl;                          # for SEEK_SET and SEEK_CUR

$ADDRESS = $RECSIZE * $RECNO;
seek(FH, $ADDRESS, SEEK_SET)        or die "Seeking: $!";
read(FH, $BUFFER, $RECSIZE) == $RECSIZE
                                    or die "Reading: $!";
@FIELDS = unpack($FORMAT, $BUFFER);
# update fields, then
$BUFFER = pack($FORMAT, @FIELDS);
seek(FH, -$RECSIZE, SEEK_CUR)       or die "Seeking: $!";
print FH $BUFFER;
close FH                            or die "Closing: $!";
#-----------------------------
# ^^INCLUDE^^ include/perl/ch08/weekearly
#-----------------------------

# ^^PLEAC^^_8.14
#-----------------------------
$old_rs = $/;                       # save old $/
$/ = "\0";                          # NULL
seek(FH, $addr, SEEK_SET)           or die "Seek error: $!\n";
$string = <FH>;                     # read string
chomp $string;                      # remove NULL
$/ = $old_rs;                       # restore old $/
#-----------------------------
{
    local $/ = "\0";
    # ...
}                           # $/ is automatically restored
#-----------------------------
# ^^INCLUDE^^ include/perl/ch08/bgets
#-----------------------------
# ^^INCLUDE^^ include/perl/ch08/strings
#-----------------------------

# ^^PLEAC^^_8.15
#-----------------------------
# $RECORDSIZE is the length of a record, in bytes.
# $TEMPLATE is the unpack template for the record
# FILE is the file to read from
# @FIELDS is an array, one element per field

until ( eof(FILE) ) {
    read(FILE, $record, $RECORDSIZE) == $RECORDSIZE
        or die "short read\n";
    @FIELDS = unpack($TEMPLATE, $record);
}
#-----------------------------
#define UT_LINESIZE           12
#define UT_NAMESIZE           8
#define UT_HOSTSIZE           16

struct utmp {                       /* here are the pack template codes */
    short ut_type;                  /* s for short, must be padded      */
    pid_t ut_pid;                   /* i for integer                    */
    char ut_line[UT_LINESIZE];      /* A12 for 12-char string           */
    char ut_id[2];                  /* A2, but need x2 for alignment    */
    time_t ut_time;                 /* l for long                       */
    char ut_user[UT_NAMESIZE];      /* A8 for 8-char string             */
    char ut_host[UT_HOSTSIZE];      /* A16 for 16-char string           */
    long ut_addr;                   /* l for long                       */
};
#-----------------------------

# ^^PLEAC^^_8.16
#-----------------------------
while (<CONFIG>) {
    chomp;                  # no newline
    s/#.*//;                # no comments
    s/^\s+//;               # no leading white
    s/\s+$//;               # no trailing white
    next unless length;     # anything left?
    my ($var, $value) = split(/\s*=\s*/, $_, 2);
    $User_Preferences{$var} = $value;
} 
#-----------------------------
do "$ENV{HOME}/.progrc";
#-----------------------------
# set class C net
NETMASK = 255.255.255.0
MTU     = 296
    
DEVICE  = cua1
RATE    = 115200
MODE    = adaptive
#-----------------------------
no strict 'refs';
$$var = $value;
#-----------------------------
# set class C net
$NETMASK = '255.255.255.0';
$MTU     = 0x128;
# Brent, please turn on the modem
$DEVICE  = 'cua1';
$RATE    = 115_200;
$MODE    = 'adaptive';
#-----------------------------
if ($DEVICE =~ /1$/) {
    $RATE =  28_800;
} else {
    $RATE = 115_200;
} 
#-----------------------------
$APPDFLT = "/usr/local/share/myprog";

do "$APPDFLT/sysconfig.pl";
do "$ENV{HOME}/.myprogrc";
#-----------------------------
do "$ENV{HOME}/.myprogrc";
    or
do "$APPDFLT/sysconfig.pl"
#-----------------------------
{ package Settings; do "$ENV{HOME}/.myprogrc" }
#-----------------------------
eval `cat $ENV{HOME}/.myprogrc`;
#-----------------------------
$file = "someprog.pl";
unless ($return = do $file) {
    warn "couldn't parse $file: $@"         if $@;
    warn "couldn't do $file: $!"            unless defined $return;
    warn "couldn't run $file"               unless $return;
}
#-----------------------------

# ^^PLEAC^^_8.17
#-----------------------------
( $dev, $ino, $mode, $nlink, 
  $uid, $gid, $rdev, $size, 
  $atime, $mtime, $ctime, 
  $blksize, $blocks )       = stat($filename)
        or die "no $filename: $!";

$mode &= 07777;             # discard file type info
#-----------------------------
$info = stat($filename)     or die "no $filename: $!";
if ($info->uid == 0) {
    print "Superuser owns $filename\n";
} 
if ($info->atime > $info->mtime) {
    print "$filename has been read since it was written.\n";
} 
#-----------------------------
use File::stat;

sub is_safe {
    my $path = shift;
    my $info = stat($path);
    return unless $info;

    # owner neither superuser nor me 
    # the real uid is in stored in the $< variable
    if (($info->uid != 0) && ($info->uid != $<)) {
        return 0;
    }

    # check whether group or other can write file.
    # use 066 to detect either reading or writing
    if ($info->mode & 022) {   # someone else can write this
        return 0 unless -d _;  # non-directories aren't safe
            # but directories with the sticky bit (01000) are
        return 0 unless $info->mode & 01000;        
    }
    return 1;
}
#-----------------------------
use Cwd;
use POSIX qw(sysconf _PC_CHOWN_RESTRICTED);
sub is_verysafe {
    my $path = shift;
    return is_safe($path) if sysconf(_PC_CHOWN_RESTRICTED);
    $path = getcwd() . '/' . $path if $path !~ m{^/};
    do {
        return unless is_safe($path);
        $path =~ s#([^/]+|/)$##;               # dirname
        $path =~ s#/$## if length($path) > 1;  # last slash
    } while length $path;

    return 1;
}
#-----------------------------
$file = "$ENV{HOME}/.myprogrc";
readconfig($file) if is_safe($file);
#-----------------------------
$file = "$ENV{HOME}/.myprogrc";
if (open(FILE, "< $file")) { 
    readconfig(*FILE) if is_safe(*FILE);
}
#-----------------------------

# ^^PLEAC^^_8.18
#-----------------------------
# ^^INCLUDE^^ include/perl/ch08/tailwtmp
#-----------------------------

# ^^PLEAC^^_8.19
#-----------------------------
#% someprog | tee /tmp/output | Mail -s 'check this' user@host.org
#-----------------------------
#% someprog | tctee f1 "|cat -n" f2 ">>f3"
#-----------------------------
# ^^INCLUDE^^ include/perl/ch08/tctee
#-----------------------------

# ^^PLEAC^^_8.20
#-----------------------------
#% laston gnat
#gnat  UID 314 at Mon May 25 08:32:52 1998 on ttyp0 from below.perl.com
#-----------------------------
# ^^INCLUDE^^ include/perl/ch08/laston
#-----------------------------

# ^^PLEAC^^_9.0
#-----------------------------
@entry = stat("/usr/bin/vi") or die "Couldn't stat /usr/bin/vi : $!";
#-----------------------------
@entry = stat("/usr/bin")    or die "Couldn't stat /usr/bin : $!";
#-----------------------------
@entry = stat(INFILE)        or die "Couldn't stat INFILE : $!";
#-----------------------------
use File::stat;

$inode = stat("/usr/bin/vi");
$ctime = $inode->ctime;
$size  = $inode->size;
#-----------------------------
open( F, "< $filename" )
    or die "Opening $filename: $!\n";
unless (-s F && -T _) {
    die "$filename doesn't have text in it.\n";
}
#-----------------------------
opendir(DIRHANDLE, "/usr/bin") or die "couldn't open /usr/bin : $!";
while ( defined ($filename = readdir(DIRHANDLE)) ) {
    print "Inside /usr/bin is something called $filename\n";
}
closedir(DIRHANDLE);
#-----------------------------

# ^^PLEAC^^_9.1
#-----------------------------
($READTIME, $WRITETIME) = (stat($filename))[8,9];

utime($NEWREADTIME, $NEWWRITETIME, $filename);
#-----------------------------
$SECONDS_PER_DAY = 60 * 60 * 24;
($atime, $mtime) = (stat($file))[8,9];
$atime -= 7 * $SECONDS_PER_DAY;
$mtime -= 7 * $SECONDS_PER_DAY;

utime($atime, $mtime, $file)
    or die "couldn't backdate $file by a week w/ utime: $!";
#-----------------------------
$mtime = (stat $file)[9];
utime(time, $mtime, $file);
#-----------------------------
use File::stat;
utime(time, stat($file)->mtime, $file);
#-----------------------------
# ^^INCLUDE^^ include/perl/ch09/uvi
#-----------------------------

# ^^PLEAC^^_9.2
#-----------------------------
unlink($FILENAME)                 or die "Can't delete $FILENAME: $!\n";
unlink(@FILENAMES) == @FILENAMES  or die "Couldn't unlink all of @FILENAMES: $!\n";
#-----------------------------
unlink($file) or die "Can't unlink $file: $!";
#-----------------------------
unless (($count = unlink(@filelist)) == @filelist) {
    warn "could only delete $count of "
            . (@filelist) . " files";
}
#-----------------------------

# ^^PLEAC^^_9.3
#-----------------------------
use File::Copy;
copy($oldfile, $newfile);
#-----------------------------
open(IN,  "< $oldfile")                     or die "can't open $oldfile: $!";
open(OUT, "> $newfile")                     or die "can't open $newfile: $!";

$blksize = (stat IN)[11] || 16384;          # preferred block size?
while ($len = sysread IN, $buf, $blksize) {
    if (!defined $len) {
        next if $! =~ /^Interrupted/;       # ^Z and fg
        die "System read error: $!\n";
    }
    $offset = 0;
    while ($len) {          # Handle partial writes.
        defined($written = syswrite OUT, $buf, $len, $offset)
            or die "System write error: $!\n";
        $len    -= $written;
        $offset += $written;
    };
}

close(IN);
close(OUT);
#-----------------------------
system("cp $oldfile $newfile");       # unix
system("copy $oldfile $newfile");     # dos, vms
#-----------------------------
use File::Copy;

copy("datafile.dat", "datafile.bak")
    or die "copy failed: $!";

move("datafile.new", "datafile.dat")
    or die "move failed: $!";
#-----------------------------

# ^^PLEAC^^_9.4
#-----------------------------
%seen = ();

sub do_my_thing {
    my $filename = shift;
    my ($dev, $ino) = stat $filename;

    unless ($seen{$dev, $ino}++) {
        # do something with $filename because we haven't
        # seen it before
    }
}
#-----------------------------
foreach $filename (@files) {
    ($dev, $ino) = stat $filename;
    push( @{ $seen{$dev,$ino} }, $filename);
}

foreach $devino (sort keys %seen) {
    ($dev, $ino) = split(/$;/o, $devino);
    if (@{$seen{$devino}} > 1) {
        # @{$seen{$devino}} is a list of filenames for the same file
    }
}
#-----------------------------

# ^^PLEAC^^_9.5
#-----------------------------
opendir(DIR, $dirname) or die "can't opendir $dirname: $!";
while (defined($file = readdir(DIR))) {
    # do something with "$dirname/$file"
}
closedir(DIR);
#-----------------------------
$dir = "/usr/local/bin";
print "Text files in $dir are:\n";
opendir(BIN, $dir) or die "Can't open $dir: $!";
while( defined ($file = readdir BIN) ) {
    print "$file\n" if -T "$dir/$file";
}
closedir(BIN);
#-----------------------------
while ( defined ($file = readdir BIN) ) {
    next if $file =~ /^\.\.?$/;     # skip . and ..
    # ...
}
#-----------------------------
use DirHandle;

sub plainfiles {
   my $dir = shift;
   my $dh = DirHandle->new($dir)   or die "can't opendir $dir: $!";
   return sort                     # sort pathnames
          grep {    -f     }       # choose only "plain" files
          map  { "$dir/$_" }       # create full paths
          grep {  !/^\./   }       # filter out dot files
          $dh->
read()
;             # read all entries
}
#-----------------------------

# ^^PLEAC^^_9.6
#-----------------------------
@list = <*.c>;
@list = glob("*.c");
#-----------------------------
opendir(DIR, $path);
@files = grep { /\.c$/ } readdir(DIR);
closedir(DIR);
#-----------------------------
use File::KGlob;

@files = glob("*.c");
#-----------------------------
@files = grep { /\.[ch]$/i } readdir(DH);
#-----------------------------
use DirHandle;

$dh = DirHandle->new($path)   or die "Can't open $path : $!\n";
@files = grep { /\.[ch]$/i } $dh->read();
#-----------------------------
opendir(DH, $dir)        or die "Couldn't open $dir for reading: $!";

@files = ();
while( defined ($file = readdir(DH)) ) {
    next unless /\.[ch]$/i;

    my $filename = "$dir/$file";
    push(@files, $filename) if -T $file;
}
#-----------------------------
@dirs = map  { $_->[1] }                # extract pathnames
        sort { $a->[0] <=> $b->[0] }    # sort names numeric
        grep { -d $_->[1] }             # path is a dir
        map  { [ $_, "$path/$_" ] }     # form (name, path)
        grep { /^\d+$/ }                # just numerics
        readdir(DIR);                   # all files
#-----------------------------

# ^^PLEAC^^_9.7
#-----------------------------
use File::Find;
sub process_file {
    # do whatever;
}
find(\&process_file, @DIRLIST);
#-----------------------------
@ARGV = qw(.) unless @ARGV;
use File::Find;
find sub { print $File::Find::name, -d && '/', "\n" }, @ARGV;
#-----------------------------
use File::Find;
@ARGV = ('.') unless @ARGV;
my $sum = 0;
find sub { $sum += -s }, @ARGV;
print "@ARGV contains $sum bytes\n";
#-----------------------------
use File::Find;
@ARGV = ('.') unless @ARGV;
my ($saved_size, $saved_name) = (-1, '');
sub biggest {
    return unless -f && -s _ > $saved_size;
    $saved_size = -s _;
    $saved_name = $File::Find::name;
}
find(\&biggest, @ARGV);
print "Biggest file $saved_name in @ARGV is $saved_size bytes long.\n";
#-----------------------------
use File::Find;
@ARGV = ('.') unless @ARGV;
my ($age, $name);
sub youngest {
    return if defined $age && $age > (stat($_))[9];
    $age = (stat(_))[9];
    $name = $File::Find::name;
}
find(\&youngest, @ARGV);
print "$name " . scalar(localtime($age)) . "\n";
#-----------------------------
# ^^INCLUDE^^ include/perl/ch09/fdirs
#-----------------------------
find sub { print $File::Find::name if -d }, @ARGV;
#-----------------------------
find { print $name if -d } @ARGV;
#-----------------------------

# ^^PLEAC^^_9.8
#-----------------------------
# ^^INCLUDE^^ include/perl/ch09/rmtree1
#-----------------------------
# ^^INCLUDE^^ include/perl/ch09/rmtree2
#-----------------------------

# ^^PLEAC^^_9.9
#-----------------------------
foreach $file (@NAMES) {
    my $newname = $file;
    # change $newname
    rename($file, $newname) or  
        warn "Couldn't rename $file to $newname: $!\n";
}
#-----------------------------
# ^^INCLUDE^^ include/perl/ch09/rename
#-----------------------------
#% rename 's/\.orig$//'  *.orig
#% rename 'tr/A-Z/a-z/ unless /^Make/'  *
#% rename '$_ .= ".bad"'  *.f
#% rename 'print "$_: "; s/foo/bar/ if <STDIN> =~ /^y/i'  *
#% find /tmp -name '*~' -print | rename 's/^(.+)~$/.#$1/'
#-----------------------------
#% rename 'use locale; $_ = lc($_) unless /^Make/' *
#-----------------------------

# ^^PLEAC^^_9.10
#-----------------------------
use File::Basename;

$base = basename($path);
$dir  = dirname($path);
($base, $dir, $ext) = fileparse($path);
#-----------------------------
$path = '/usr/lib/libc.a';
$file = basename($path);    
$dir  = dirname($path);     

print "dir is $dir, file is $file\n";
# dir is /usr/lib, file is libc.a
#-----------------------------
$path = '/usr/lib/libc.a';
($name,$dir,$ext) = fileparse($path,'\..*');

print "dir is $dir, name is $name, extension is $ext\n";
# dir is /usr/lib/, name is libc, extension is .a
#-----------------------------
fileparse_set_fstype("MacOS");
$path = "Hard%20Drive:System%20Folder:README.txt";
($name,$dir,$ext) = fileparse($path,'\..*');

print "dir is $dir, name is $name, extension is $ext\n";
# dir is Hard%20Drive:System%20Folder, name is README, extension is .txt
#-----------------------------
sub extension {
    my $path = shift;
    my $ext = (fileparse($path,'\..*'))[2];
    $ext =~ s/^\.//;
    return $ext;
}
#-----------------------------

# ^^PLEAC^^_9.11
#-----------------------------
# ^^INCLUDE^^ include/perl/ch09/symirror
#-----------------------------

# ^^PLEAC^^_9.12
#-----------------------------
#% lst -l /etc
#12695 0600      1     root    wheel      512 Fri May 29 10:42:41 1998 
#
#    /etc/ssh_random_seed
#
#12640 0644      1     root    wheel    10104 Mon May 25  7:39:19 1998 
#
#    /etc/ld.so.cache
#
#12626 0664      1     root    wheel    12288 Sun May 24 19:23:08 1998 
#
#    /etc/psdevtab
#
#12304 0644      1     root     root      237 Sun May 24 13:59:33 1998 
#
#    /etc/exports
#
#12309 0644      1     root     root     3386 Sun May 24 13:24:33 1998 
#
#    /etc/inetd.conf
#
#12399 0644      1     root     root    30205 Sun May 24 10:08:37 1998 
#
#    /etc/sendmail.cf
#
#18774 0644      1     gnat  perldoc     2199 Sun May 24  9:35:57 1998 
#
#    /etc/X11/XMetroconfig
#
#12636 0644      1     root    wheel      290 Sun May 24  9:05:40 1998 
#
#    /etc/mtab
#
#12627 0640      1     root     root        0 Sun May 24  8:24:31 1998 
#
#    /etc/wtmplock
#
#12310 0644      1     root  tchrist       65 Sun May 24  8:23:04 1998 
#
#    /etc/issue
#
#....
#-----------------------------
# ^^INCLUDE^^ include/perl/ch09/lst
#-----------------------------

# ^^PLEAC^^_10.0
#-----------------------------
sub hello { 
    $greeted++;          # global variable 
    print "hi there!\n";
}
#-----------------------------
hello();                 # call subroutine hello with no arguments/parameters
#-----------------------------

# ^^PLEAC^^_10.1
#-----------------------------
sub hypotenuse {
    return sqrt( ($_[0] ** 2) + ($_[1] ** 2) );
}

$diag = hypotenuse(3,4);  # $diag is 5
#-----------------------------
sub hypotenuse {
    my ($side1, $side2) = @_;
    return sqrt( ($side1 ** 2) + ($side2 ** 2) );
}
#-----------------------------
print hypotenuse(3, 4), "\n";               # prints 5

@a = (3, 4);
print hypotenuse(@a), "\n";                 # prints 5
#-----------------------------
@both = (@men, @women);
#-----------------------------
@nums = (1.4, 3.5, 6.7);
@ints = int_all(@nums);        # @nums unchanged
sub int_all {
    my @retlist = @_;          # make safe copy for return
    for my $n (@retlist) { $n = int($n) } 
    return @retlist;
} 
#-----------------------------
@nums = (1.4, 3.5, 6.7);
trunc_em(@nums);               # @nums now (1,3,6)
sub trunc_em {
    for (@_) { $_ = int($_) }  # truncate each argument
} 
#-----------------------------
$line = chomp(<>);                  # WRONG
#-----------------------------

# ^^PLEAC^^_10.2
#-----------------------------
sub somefunc {
    my $variable;                 # $variable is invisible outside somefunc()
    my ($another, @an_array, %a_hash);     # declaring many variables at once

    # ...
}
#-----------------------------
my ($name, $age) = @ARGV;
my $start        = fetch_time();
#-----------------------------
my ($a, $b) = @pair;
my $c = fetch_time();

sub check_x {
    my $x = $_[0];       
    my $y = "whatever";  
    run_check();
    if ($condition) {
        print "got $x\n";
    }
}
#-----------------------------
sub save_array {
    my @arguments = @_;
    push(@Global_Array, \@arguments);
}
#-----------------------------

# ^^PLEAC^^_10.3
#-----------------------------
{
    my $variable;
    sub mysub {
        # ... accessing $variable
    }
}
#-----------------------------
BEGIN {
    my $variable = 1;                       # initial value
    sub othersub {                          # ... accessing $variable
    }
}
#-----------------------------
{
    my $counter;
    sub next_counter { return ++$counter }
}
#-----------------------------
BEGIN {
    my $counter = 42;
    sub next_counter { return ++$counter }
    sub prev_counter { return --$counter }
}
#-----------------------------

# ^^PLEAC^^_10.4
#-----------------------------
$this_function = (caller(0))[3];
#-----------------------------
($package, $filename, $line, $subr, $has_args, $wantarray )= caller($i);
#   0         1         2       3       4          5
#-----------------------------
$me  = whoami();
$him = whowasi();

sub whoami  { (caller(1))[3] }
sub whowasi { (caller(2))[3] }
#-----------------------------

# ^^PLEAC^^_10.5
#-----------------------------
array_diff( \@array1, \@array2 );
#-----------------------------
@a = (1, 2);
@b = (5, 8);
@c = add_vecpair( \@a, \@b );
print "@c\n";
6 10
 

sub add_vecpair {       # assumes both vectors the same length
    my ($x, $y) = @_;   # copy in the array references
    my @result;

    for (my $i=0; $i < @$x; $i++) {
      $result[$i] = $x->[$i] + $y->[$i];
    }

    return @result;
}
#-----------------------------
unless (@_ == 2 && ref($x) eq 'ARRAY' && ref($y) eq 'ARRAY') {
    die "usage: add_vecpair ARRAYREF1 ARRAYREF2";
}
#-----------------------------

# ^^PLEAC^^_10.6
#-----------------------------
if (wantarray()) {
    # list context
} 
elsif (defined wantarray()) {
    # scalar context
} 
else {
    # void context
} 
#-----------------------------
if (wantarray()) {
    print "In list context\n";
    return @many_things;
} elsif (defined wantarray()) {
    print "In scalar context\n";
    return $one_thing;
} else {
    print "In void context\n";
    return;  # nothing
}

mysub();                    # void context

$a = mysub();               # scalar context
if (mysub()) {  }           # scalar context

@a = mysub();               # list context
print mysub();              # list context
#-----------------------------

# ^^PLEAC^^_10.7
#-----------------------------
thefunc(INCREMENT => "20s", START => "+5m", FINISH => "+30m");
thefunc(START => "+5m", FINISH => "+30m");
thefunc(FINISH => "+30m");
thefunc(START => "+5m", INCREMENT => "15s");
#-----------------------------
sub thefunc {
    my %args = ( 
        INCREMENT   => '10s', 
        FINISH      => 0, 
        START       => 0, 
        @_,         # argument pair list goes here
    );
    if ($args{INCREMENT}  =~ /m$/ ) { ..... }
} 
#-----------------------------

# ^^PLEAC^^_10.8
#-----------------------------
($a, undef, $c) = func();
#-----------------------------
($a, $c) = (func())[0,2];
#-----------------------------
($dev,$ino,$DUMMY,$DUMMY,$uid) = stat($filename);
#-----------------------------
($dev,$ino,undef,undef,$uid)   = stat($filename);
#-----------------------------
($dev,$ino,$uid,$gid)   = (stat($filename))[0,1,4,5];
#-----------------------------
() = some_function();
#-----------------------------

# ^^PLEAC^^_10.9
#-----------------------------
($array_ref, $hash_ref) = somefunc();

sub somefunc {
    my @array;
    my %hash;

    # ...

    return ( \@array, \%hash );
}
#-----------------------------
sub fn { 
    .....
    return (\%a, \%b, \%c); # or                           
    return \(%a,  %b,  %c); # same thing
}
#-----------------------------
(%h0, %h1, %h2)  = fn();    # WRONG!
@array_of_hashes = fn();    # eg: $array_of_hashes[2]->{"keystring"}
($r0, $r1, $r2)  = fn();    # eg: $r2->{"keystring"}

#-----------------------------

# ^^PLEAC^^_10.10
#-----------------------------
return;
#-----------------------------
sub empty_retval {
    return ( wantarray ? () : undef );
}
#-----------------------------
if (@a = yourfunc()) { ... }
#-----------------------------
unless ($a = sfunc()) { die "sfunc failed" }
unless (@a = afunc()) { die "afunc failed" }
unless (%a = hfunc()) { die "hfunc failed" }
#-----------------------------
ioctl(....) or die "can't ioctl: $!";
#-----------------------------

# ^^PLEAC^^_10.11
#-----------------------------
@results = myfunc 3, 5;
#-----------------------------
@results = myfunc(3, 5);
#-----------------------------
sub myfunc($);
@results = myfunc 3, 5;
#-----------------------------
@results = ( myfunc(3), 5 );
#-----------------------------
sub LOCK_SH () { 1 }
sub LOCK_EX () { 2 }
sub LOCK_UN () { 4 }
#-----------------------------
sub mypush (\@@) {
  my $array_ref = shift;
  my @remainder = @_;

  # ...
}
#-----------------------------
 mypush( $x > 10 ? @a : @b , 3, 5 );          # WRONG
#-----------------------------
 mypush( @{ $x > 10 ? \@a : \@b }, 3, 5 );    # RIGHT
#-----------------------------
sub hpush(\%@) {
    my $href = shift;
    while ( my ($k, $v) = splice(@_, 0, 2) ) {
        $href->{$k} = $v;
    } 
} 
hpush(%pieces, "queen" => 9, "rook" => 5);
#-----------------------------

# ^^PLEAC^^_10.12
#-----------------------------
die "some message";         # raise exception
#-----------------------------
eval { func() };
if ($@) {
    warn "func raised an exception: $@";
} 
#-----------------------------
eval { $val = func() };
warn "func blew up: $@" if $@;
#-----------------------------
eval { $val = func() };
if ($@ && $@ !~ /Full moon!/) {
    die;    # re-raise unknown errors
}
#-----------------------------
if (defined wantarray()) {
        return;
} else {
    die "pay attention to my error!";
}
#-----------------------------

# ^^PLEAC^^_10.13
#-----------------------------
$age = 18;          # global variable
if (CONDITION) {
    local $age = 23;
    func();         # sees temporary value of 23
} # restore old value at block exit
#-----------------------------
$para = get_paragraph(*FH);        # pass filehandle glob 
$para = get_paragraph(\*FH);       # pass filehandle by glob reference
$para = get_paragraph(*IO{FH});    # pass filehandle by IO reference
sub get_paragraph {
    my $fh = shift;  
    local $/ = '';        
    my $paragraph = <$fh>;
    chomp($paragraph);
    return $paragraph;
} 
#-----------------------------
$contents = get_motd();
sub get_motd {
    local *MOTD;
    open(MOTD, "/etc/motd")        or die "can't open motd: $!";
    local $/ = undef;  # slurp full file;
    local $_ = <MOTD>;
    close (MOTD);
    return $_;
} 
#-----------------------------
return *MOTD;
#-----------------------------
my @nums = (0 .. 5);
sub first { 
    local $nums[3] = 3.14159;
    second();
}
sub second {
    print "@nums\n";
} 
second();
0 1 2 3 4 5

first();
0 1 2 3.14159 4 5
#-----------------------------
sub first {
    local $SIG{INT} = 'IGNORE';
    second();
} 
#-----------------------------
sub func {
    local($x, $y) = @_;
    #....
} 
#-----------------------------
sub func {
    my($x, $y) = @_;
    #....
} 
#-----------------------------
&func(*Global_Array);
sub func {
    local(*aliased_array) = shift;
    for (@aliased_array) { .... }
} 
#-----------------------------
func(\@Global_Array);
sub func {
    my $array_ref  = shift;
    for (@$array_ref) { .... }
} 
#-----------------------------

# ^^PLEAC^^_10.14
#-----------------------------
undef &grow;                # silence -w complaints of redefinition
*grow = \&expand;           
grow();                     # calls expand()

{
    local *grow = \&shrink;         # only until this block exists
        grow();                 # calls shrink()
}
#-----------------------------
*one::var = \%two::Table;   # make %one::var alias for %two::Table
*one::big = \&two::small;   # make &one::big alias for &two::small
#-----------------------------
local *fred = \&barney;     # temporarily alias &fred to &barney
#-----------------------------
$string =  red("careful here");
print $string;
<FONT COLOR='red'>careful here</FONT>
#-----------------------------
sub red { "<FONT COLOR='red'>@_</FONT>" }
#-----------------------------
sub color_font {
    my $color = shift;
    return "<FONT COLOR='$color'>@_</FONT>";
}
sub red    { color_font("red", @_)     }
sub green  { color_font("green", @_)   }
sub blue   { color_font("blue", @_)    }
sub purple { color_font("purple", @_)  }
# etc
#-----------------------------
@colors = qw(red blue green yellow orange purple violet);
for my $name (@colors) {
    no strict 'refs';
    *$name = sub { "<FONT COLOR='$name'>@_</FONT>" };
} 
#-----------------------------
*$name = sub ($) { "<FONT COLOR='$name'>$_[0]</FONT>" };
#-----------------------------

# ^^PLEAC^^_10.15
#-----------------------------
sub AUTOLOAD {
    use vars qw($AUTOLOAD);
    my $color = $AUTOLOAD;
    $color =~ s/.*:://;
    return "<FONT COLOR='$color'>@_</FONT>";
} 
#note: sub chartreuse isn't defined.
print chartreuse("stuff");
#-----------------------------
{
    local *yellow = \&violet;  
    local (*red, *green) = (\&green, \&red);
    print_stuff();
} 
#-----------------------------

# ^^PLEAC^^_10.16
#-----------------------------
sub outer {
    my $x = $_[0] + 35;
    sub inner { return $x * 19 }   # WRONG
    return $x + inner();
} 
#-----------------------------
sub outer {
    my $x = $_[0] + 35;
    local *inner = sub { return $x * 19 };
    return $x + inner();
} 
#-----------------------------

# ^^PLEAC^^_10.17
#-----------------------------
# ^^INCLUDE^^ include/perl/ch10/bysub1
#-----------------------------
# ^^INCLUDE^^ include/perl/ch10/bysub2
#-----------------------------
# ^^INCLUDE^^ include/perl/ch10/bysub3
#-----------------------------
# ^^INCLUDE^^ include/perl/ch10/datesort
#-----------------------------

# ^^PLEAC^^_11.0
#-----------------------------
print $$sref;    # prints the scalar value that the reference $sref refers to
$$sref = 3;      # assigns to $sref's referent
#-----------------------------
print ${$sref};             # prints the scalar $sref refers to
${$sref} = 3;               # assigns to $sref's referent
#-----------------------------
$aref = \@array;
#-----------------------------
$pi = \3.14159;
$$pi = 4;           # runtime error
#-----------------------------
$aref = [ 3, 4, 5 ];                                # new anonymous array
$href = { "How" => "Now", "Brown" => "Cow" };       # new anonymous hash
#-----------------------------
undef $aref;
@$aref = (1, 2, 3);
print $aref;
ARRAY(0x80c04f0)
#-----------------------------
$a[4][23][53][21] = "fred";
print $a[4][23][53][21];
fred

print $a[4][23][53];
ARRAY(0x81e2494)

print $a[4][23];
ARRAY(0x81e0748)

print $a[4];
ARRAY(0x822cd40)
#-----------------------------
$op_cit = cite($ibid)       or die "couldn't make a reference";
#-----------------------------
$Nat = { "Name"     => "Leonhard Euler",
         "Address"  => "1729 Ramanujan Lane\nMathworld, PI 31416",
         "Birthday" => 0x5bb5580,
       };
#-----------------------------

# ^^PLEAC^^_11.1
#-----------------------------
$aref               = \@array;
$anon_array         = [1, 3, 5, 7, 9];
$anon_copy          = [ @array ];
@$implicit_creation = (2, 4, 6, 8, 10);
#-----------------------------
push(@$anon_array, 11);
#-----------------------------
$two = $implicit_creation->[0];
#-----------------------------
$last_idx  = $#$aref;
$num_items = @$aref;
#-----------------------------
$last_idx  = $#{ $aref };
$num_items = scalar @{ $aref };
#-----------------------------
# check whether $someref contains a simple array reference
if (ref($someref) ne 'ARRAY') {
    die "Expected an array reference, not $someref\n";
}

print "@{$array_ref}\n";        # print original data

@order = sort @{ $array_ref };  # sort it

push @{ $array_ref }, $item;    # append new element to orig array  
#-----------------------------
sub array_ref {
    my @array;
    return \@array;
}

$aref1 = array_ref();
$aref2 = array_ref();
#-----------------------------
print $array_ref->[$N];         # access item in position N (best)
print $$array_ref[$N];          # same, but confusing
print ${$array_ref}[$N];        # same, but still confusing, and ugly to boot
#-----------------------------
@$pie[3..5];                    # array slice, but a little confusing to read
@{$pie}[3..5];                  # array slice, easier (?) to read
#-----------------------------
@{$pie}[3..5] = ("blackberry", "blueberry", "pumpkin");
#-----------------------------
$sliceref = \@{$pie}[3..5];     # WRONG!
#-----------------------------
foreach $item ( @{$array_ref} ) {   
    # $item has data
}

for ($idx = 0; $idx <= $#{ $array_ref }; $idx++) {  
    # $array_ref->[$idx] has data
}
#-----------------------------

# ^^PLEAC^^_11.2
#-----------------------------
push(@{ $hash{"KEYNAME"} }, "new value");
#-----------------------------
foreach $string (keys %hash) {
    print "$string: @{$hash{$string}}\n"; 
} 
#-----------------------------
$hash{"a key"} = [ 3, 4, 5 ];       # anonymous array
#-----------------------------
@values = @{ $hash{"a key"} };
#-----------------------------
push @{ $hash{"a key"} }, $value;
#-----------------------------
@residents = @{ $phone2name{$number} };
#-----------------------------
@residents = exists( $phone2name{$number} )
                ? @{ $phone2name{$number} }
                : ();
#-----------------------------

# ^^PLEAC^^_11.3
#-----------------------------
$href = \%hash;
$anon_hash = { "key1" => "value1", "key2" => "value2", ... };
$anon_hash_copy = { %hash };
#-----------------------------
%hash  = %$href;
$value = $href->{$key};
@slice = @$href{$key1, $key2, $key3};  # note: no arrow!
@keys  = keys %$href;
#-----------------------------
if (ref($someref) ne 'HASH') {
    die "Expected a hash reference, not $someref\n";
}
#-----------------------------
foreach $href ( \%ENV, \%INC ) {       # OR: for $href ( \(%ENV,%INC) ) {
    foreach $key ( keys %$href ) {
        print "$key => $href->{$key}\n";
    }
}
#-----------------------------
@values = @$hash_ref{"key1", "key2", "key3"};

for $val (@$hash_ref{"key1", "key2", "key3"}) {
    $val += 7;   # add 7 to each value in hash slice
} 
#-----------------------------

# ^^PLEAC^^_11.4
#-----------------------------
$cref = \&func;
$cref = sub { ... };
#-----------------------------
@returned = $cref->(@arguments);
@returned = &$cref(@arguments);
#-----------------------------
$funcname = "thefunc";
&$funcname();
#-----------------------------
my %commands = (
    "happy" => \&joy,
    "sad"   => \&sullen,
    "done"  => sub { die "See ya!" },
    "mad"   => \&angry,
);

print "How are you? ";
chomp($string = <STDIN>);
if ($commands{$string}) {
    $commands{$string}->();
} else {
    print "No such command: $string\n";
} 
#-----------------------------
sub counter_maker {
    my $start = 0;
    return sub {                      # this is a closure
        return $start++;              # lexical from enclosing scope
    };
}

$counter = counter_maker();

for ($i = 0; $i < 5; $i ++) {
    print &$counter, "\n";
}
#-----------------------------
$counter1 = counter_maker();
$counter2 = counter_maker();

for ($i = 0; $i < 5; $i ++) {
    print &$counter1, "\n";
}

print &$counter1, " ", &$counter2, "\n";
0

1

2

3

4

5 0
#-----------------------------
sub timestamp {
    my $start_time = time(); 
    return sub { return time() - $start_time };
} 
$early = timestamp(); 
sleep 20; 
$later = timestamp(); 
sleep 10;
printf "It's been %d seconds since early.\n", $early->();
printf "It's been %d seconds since later.\n", $later->();
#It's been 30 seconds since early.
#
#It's been 10 seconds since later.
#-----------------------------

# ^^PLEAC^^_11.5
#-----------------------------
$scalar_ref = \$scalar;       # get reference to named scalar
#-----------------------------
undef $anon_scalar_ref;
$$anon_scalar_ref = 15;
#-----------------------------
$anon_scalar_ref = \15;
#-----------------------------
print ${ $scalar_ref };       # dereference it
${ $scalar_ref } .= "string"; # alter referent's value
#-----------------------------
sub new_anon_scalar {
    my $temp;
    return \$temp;
}
#-----------------------------
$sref = new_anon_scalar();
$$sref = 3;
print "Three = $$sref\n";
@array_of_srefs = ( new_anon_scalar(), new_anon_scalar() );
${ $array[0] } = 6.02e23;
${ $array[1] } = "avocado";
print "\@array contains: ", join(", ", map { $$_ } @array ), "\n";
#-----------------------------
$var        = `uptime`;     # $var holds text
$vref       = \$var;        # $vref "points to" $var
if ($$vref =~ /load/) {}    # look at $var, indirectly
chomp $$vref;               # alter $var, indirectly
#-----------------------------
# check whether $someref contains a simple scalar reference
if (ref($someref) ne 'SCALAR') {
    die "Expected a scalar reference, not $someref\n";

}
#-----------------------------

# ^^PLEAC^^_11.6
#-----------------------------
@array_of_scalar_refs = ( \$a, \$b );
#-----------------------------
@array_of_scalar_refs = \( $a, $b );
#-----------------------------
${ $array_of_scalar_refs[1] } = 12;         # $b = 12
#-----------------------------
($a, $b, $c, $d) = (1 .. 4);        # initialize
@array =  (\$a, \$b, \$c, \$d);     # refs to each scalar
@array = \( $a,  $b,  $c,  $d);     # same thing!
@array = map { \my $anon } 0 .. 3;  # allocate 4 anon scalarresf

${ $array[2] } += 9;                # $c now 12

${ $array[ $#array ] } *= 5;        # $d now 20
${ $array[-1] }        *= 5;        # same; $d now 100

$tmp   = $array[-1];                # using temporary
$$tmp *= 5;                         # $d now 500
#-----------------------------
use Math::Trig qw(pi);              # load the constant pi
foreach $sref (@array) {            # prepare to change $a,$b,$c,$d
    ($$sref **= 3) *= (4/3 * pi);   # replace with spherical volumes
}
#-----------------------------

# ^^PLEAC^^_11.7
#-----------------------------
$c1 = mkcounter(20); 
$c2 = mkcounter(77);

printf "next c1: %d\n", $c1->{NEXT}->();  # 21 
printf "next c2: %d\n", $c2->{NEXT}->();  # 78 
printf "next c1: %d\n", $c1->{NEXT}->();  # 22 
printf "last c1: %d\n", $c1->{PREV}->();  # 21 
printf "old  c2: %d\n", $c2->{RESET}->(); # 77
#-----------------------------
sub mkcounter {
    my $count  = shift; 
    my $start  = $count; 
    my $bundle = { 
        "NEXT"   => sub { return ++$count  }, 
        "PREV"   => sub { return --$count  }, 
        "GET"    => sub { return $count    },
        "SET"    => sub { $count = shift   }, 
        "BUMP"   => sub { $count += shift  }, 
        "RESET"  => sub { $count = $start  },
    }; 
    $bundle->{"LAST"} = $bundle->{"PREV"}; 
    return $bundle;
}
#-----------------------------

# ^^PLEAC^^_11.8
#-----------------------------
$mref = sub { $obj->meth(@_) }; 
# later...  
$mref->("args", "go", "here");
#-----------------------------
$sref = \$obj->meth;
#-----------------------------
$cref = $obj->can("meth");
#-----------------------------

# ^^PLEAC^^_11.9
#-----------------------------
$record = {
    NAME   => "Jason",
    EMPNO  => 132,
    TITLE  => "deputy peon",
    AGE    => 23,
    SALARY => 37_000,
    PALS   => [ "Norbert", "Rhys", "Phineas"],
};

printf "I am %s, and my pals are %s.\n",
    $record->{NAME},
    join(", ", @{$record->{PALS}});
#-----------------------------
# store record
$byname{ $record->{NAME} } = $record;

# later on, look up by name
if ($rp = $byname{"Aron"}) {        # false if missing
    printf "Aron is employee %d.\n", $rp->{EMPNO};
}

# give jason a new pal
push @{$byname{"Jason"}->{PALS}}, "Theodore";
printf "Jason now has %d pals\n", scalar @{$byname{"Jason"}->{PALS}};
#-----------------------------
# Go through all records
while (($name, $record) = each %byname) {
    printf "%s is employee number %d\n", $name, $record->{EMPNO};
}
#-----------------------------
# store record
$employees[ $record->{EMPNO} ] = $record;

# lookup by id
if ($rp = $employee[132]) {
    printf "employee number 132 is %s\n", $rp->{NAME};
}
#-----------------------------
$byname{"Jason"}->{SALARY} *= 1.035;
#-----------------------------
@peons   = grep { $_->{TITLE} =~ /peon/i } @employees;
@tsevens = grep { $_->{AGE}   == 27 }      @employees;
#-----------------------------
# Go through all records
foreach $rp (sort { $a->{AGE} <=> $b->{AGE} } values %byname) {
    printf "%s is age %d.\n", $rp->{NAME}, $rp->{AGE};
    # or with a hash slice on the reference
    printf "%s is employee number %d.\n", @$rp{'NAME','EMPNO'};
}
#-----------------------------
# use @byage, an array of arrays of records
push @{ $byage[ $record->{AGE} ] }, $record;
#-----------------------------
for ($age = 0; $age <= $#byage; $age++) {
    next unless $byage[$age];
    print "Age $age: ";
    foreach $rp (@{$byage[$age]}) {
        print $rp->{NAME}, " ";
    }
    print "\n";
}
#-----------------------------
for ($age = 0; $age <= $#byage; $age++) {
    next unless $byage[$age];
    printf "Age %d: %s\n", $age,
        join(", ", map {$_->{NAME}} @{$byage[$age]});

}
#-----------------------------

# ^^PLEAC^^_11.10
#-----------------------------
FieldName: Value
#-----------------------------
foreach $record (@Array_of_Records) { 
    for $key (sort keys %$record) {
        print "$key: $record->{$key}\n";
    } 
    print "\n";
}
#-----------------------------
$/ = "";                # paragraph read mode
while (<>) {
    my @fields = split /^([^:]+):\s*/m;
    shift @fields;      # for leading null field
    push(@Array_of_Records, { map /(.*)/, @fields });
} 
#-----------------------------

# ^^PLEAC^^_11.11
#-----------------------------
DB<1> $reference = [ { "foo" => "bar" }, 3, sub { print "hello, world\n" } ];
DB<2> x $reference
  0  ARRAY(0x1d033c)

    0  HASH(0x7b390)

       'foo' = 'bar'>

    1  3

    2  CODE(0x21e3e4)

       - & in ???>
#-----------------------------
use Data::Dumper;
print Dumper($reference);
#-----------------------------
D<1> x \@INC
  0  ARRAY(0x807d0a8)

     0  '/home/tchrist/perllib' 

     1  '/usr/lib/perl5/i686-linux/5.00403'

     2  '/usr/lib/perl5' 

     3  '/usr/lib/perl5/site_perl/i686-linux' 

     4  '/usr/lib/perl5/site_perl' 

     5  '.'
#-----------------------------
{ package main; require "dumpvar.pl" } 
*dumpvar = \&main::dumpvar if __PACKAGE__ ne 'main';
dumpvar("main", "INC");             # show both @INC and %INC
#-----------------------------
@INC = (

   0  '/home/tchrist/perllib/i686-linux'

   1  '/home/tchrist/perllib'

   2  '/usr/lib/perl5/i686-linux/5.00404'

   3  '/usr/lib/perl5'

   4  '/usr/lib/perl5/site_perl/i686-linux'

   5  '/usr/lib/perl5/site_perl'

   6  '.'

)

%INC = (

   'dumpvar.pl' = '/usr/lib/perl5/i686-linux/5.00404/dumpvar.pl'

   'strict.pm' = '/usr/lib/perl5/i686-linux/5.00404/strict.pm'

)
#-----------------------------
use Data::Dumper; 
print Dumper(\@INC); 
$VAR1 = [

      '/home/tchrist/perllib', 

      '/usr/lib/perl5/i686-linux/5.00403',

      '/usr/lib/perl5', 

      '/usr/lib/perl5/site_perl/i686-linux',

      '/usr/lib/perl5/site_perl', 

      '.'

];
#-----------------------------

# ^^PLEAC^^_11.12
#-----------------------------
use Storable;

$r2 = dclone($r1);
#-----------------------------
@original = ( \@a, \@b, \@c );
@surface = @original;
#-----------------------------
@deep = map { [ @$_ ] } @original;
#-----------------------------
use Storable qw(dclone); 
$r2 = dclone($r1);
#-----------------------------
%newhash = %{ dclone(\%oldhash) };
#-----------------------------

# ^^PLEAC^^_11.13
#-----------------------------
use Storable; 
store(\%hash, "filename");

# later on...  
$href = retrieve("filename");        # by ref
%hash = %{ retrieve("filename") };   # direct to hash
#-----------------------------
use Storable qw(nstore); 
nstore(\%hash, "filename"); 
# later ...  
$href = retrieve("filename");
#-----------------------------
use Storable qw(nstore_fd);
use Fcntl qw(:DEFAULT :flock);
sysopen(DF, "/tmp/datafile", O_RDWR|O_CREAT, 0666) 
    or die "can't open /tmp/datafile: $!";
flock(DF, LOCK_EX)           or die "can't lock /tmp/datafile: $!";
nstore_fd(\%hash, *DF)
    or die "can't store hash\n";
truncate(DF, tell(DF));
close(DF);
#-----------------------------
use Storable;
use Fcntl qw(:DEFAULT :flock);
open(DF, "< /tmp/datafile")      or die "can't open /tmp/datafile: $!";
flock(DF, LOCK_SH)               or die "can't lock /tmp/datafile: $!";
$href = retrieve(*DF);
close(DF);
#-----------------------------

# ^^PLEAC^^_11.14
#-----------------------------
use MLDBM qw(DB_File);
use Fcntl;                            

tie(%hash, 'MLDBM', 'testfile.db', O_CREAT|O_RDWR, 0666)
    or die "can't open tie to testfile.db: $!";

# ... act on %hash

untie %hash;
#-----------------------------
use MLDBM qw(DB_File);
use Fcntl;                            
tie(%hash, 'MLDBM', 'testfile.db', O_CREAT|O_RDWR, 0666)
    or die "can't open tie to testfile.db: $!";
#-----------------------------
# this doesn't work!
$hash{"some key"}[4] = "fred";

# RIGHT
$aref = $hash{"some key"};
$aref->[4] = "fred";
$hash{"some key"} = $aref;
#-----------------------------

# ^^PLEAC^^_11.15
#-----------------------------
# ^^INCLUDE^^ include/perl/ch11/bintree
#-----------------------------

# ^^PLEAC^^_12.0
#-----------------------------
package Alpha;
$name = "first";

package Omega;
$name = "last";

package main;
print "Alpha is $Alpha::name, Omega is $Omega::name.\n";
Alpha is first, Omega is last.
#-----------------------------
require "FileHandle.pm";            # run-time load
require FileHandle;                 # ".pm" assumed; same as previous
use FileHandle;                     # compile-time load

require "Cards/Poker.pm";           # run-time load
require Cards::Poker;               # ".pm" assumed; same as previous
use Cards::Poker;                   # compile-time load
#-----------------------------
1    package Cards::Poker;
2    use Exporter;
3    @ISA = ('Exporter');
4    @EXPORT = qw(&shuffle @card_deck);
5    @card_deck = ();                       # initialize package global
6    sub shuffle { }                        # fill-in definition later
7    1;                                     # don't forget this
#-----------------------------

# ^^PLEAC^^_12.1
#-----------------------------
package YourModule;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
$VERSION = 1.00;              # Or higher
@ISA = qw(Exporter);

@EXPORT      = qw(...);       # Symbols to autoexport (:DEFAULT tag)
@EXPORT_OK   = qw(...);       # Symbols to export on request
%EXPORT_TAGS = (              # Define names for sets of symbols
    TAG1 => [...],
    TAG2 => [...],
    ...
);

########################
# your code goes here
########################

1;                            # this should be your last line
#-----------------------------
use YourModule;               # Import default symbols into my package.
use YourModule qw(...);       # Import listed symbols into my package.
use YourModule ();            # Do not import any symbols
use YourModule qw(:TAG1);     # Import whole tag set
#-----------------------------
    @EXPORT = qw(&F1 &F2 @List);
    @EXPORT = qw( F1  F2 @List);        # same thing
#-----------------------------
    @EXPORT_OK = qw(Op_Func %Table);
#-----------------------------
    use YourModule qw(Op_Func %Table F1);
#-----------------------------
    use YourModule qw(:DEFAULT %Table);
#-----------------------------
    %EXPORT_TAGS = (
        Functions => [ qw(F1 F2 Op_Func) ],
        Variables => [ qw(@List %Table)  ],
);
#-----------------------------
    use YourModule qw(:Functions %Table);
#-----------------------------
    @{
 
$YourModule::EXPORT_TAGS{Functions}
 
}
, 
#-----------------------------

# ^^PLEAC^^_12.2
#-----------------------------
# no import
BEGIN {
    unless (eval "require $mod") {
        warn "couldn't load $mod: $@";
    }
}

# imports into current package
BEGIN {
    unless (eval "use $mod") {
        warn "couldn't load $mod: $@";
    }
}
#-----------------------------
BEGIN {
    my($found, @DBs, $mod);
    $found = 0;
    @DBs = qw(Giant::Eenie Giant::Meanie Mouse::Mynie Moe);
    for $mod (@DBs) {
        if (eval "require $mod") {
            $mod->
import
();         # if needed
            $found = 1;
            last;
        }
    }
    die "None of @DBs loaded" unless $found;
}
#-----------------------------

# ^^PLEAC^^_12.3
#-----------------------------
BEGIN {
    unless (@ARGV == 2 && (2 == grep {/^\d+$/} @ARGV)) {
        die "usage: $0 num1 num2\n";
    }
}
use Some::Module;
use More::Modules;
#-----------------------------
if ($opt_b) {
    require Math::BigInt;
}
#-----------------------------
use Fcntl qw(O_EXCL O_CREAT O_RDWR);
#-----------------------------
require Fcntl;
Fcntl->import(qw(O_EXCL O_CREAT O_RDWR));
#-----------------------------
sub load_module {
    require $_[0];  #WRONG
    import  $_[0];  #WRONG
}
#-----------------------------
load_module('Fcntl', qw(O_EXCL O_CREAT O_RDWR));

sub load_module {
    eval "require $_[0]";
    die if $@;
    $_[0]->import(@_[1 .. $#_]);
}
#-----------------------------
use autouse Fcntl => qw( O_EXCL() O_CREAT() O_RDWR() );
#-----------------------------

# ^^PLEAC^^_12.4
#-----------------------------
package Alpha;
my $aa = 10;
   $x = "azure";

package Beta;
my $bb = 20;
   $x = "blue";

package main;
print "$aa, $bb, $x, $Alpha::x, $Beta::x\n";
10, 20, , azure, blue
#-----------------------------
# Flipper.pm
package Flipper;
use strict;

require Exporter;
use vars qw(@ISA @EXPORT $VERSION);
@ISA     = qw(Exporter);
@EXPORT  = qw(flip_words flip_boundary);
$VERSION = 1.0;

my $Separatrix = ' ';  # default to blank; must precede functions

sub flip_boundary {
    my $prev_sep = $Separatrix;
    if (@_) { $Separatrix = $_[0] }
    return $prev_sep;
}
sub flip_words {
    my $line  = $_[0];
    my @words = split($Separatrix, $line);
    return join($Separatrix, reverse @words);
}
1;
#-----------------------------

# ^^PLEAC^^_12.5
#-----------------------------
$this_pack = __PACKAGE__;
#-----------------------------
$that_pack = caller();
#-----------------------------
print "I am in package __PACKAGE__\n";              # WRONG!
I am in package __PACKAGE__
#-----------------------------
package Alpha;
runit('$line = <TEMP>');

package Beta;
sub runit {
    my $codestr = shift;
    eval $codestr;
    die if $@;
}
#-----------------------------
package Beta;
sub runit {
    my $codestr = shift;
    my $hispack = caller;
    eval "package $hispack; $codestr";
    die if $@;
}
#-----------------------------
package Alpha;
runit( sub { $line = <TEMP> } );

package Beta;
sub runit {
    my $coderef = shift;
    &$coderef();
}
#-----------------------------
open (FH, "< /etc/termcap")
    or die "can't open /etc/termcap: $!";
($a, $b, $c) = nreadline(3, 'FH');

use Symbol ();
use Carp;
sub nreadline {
    my ($count, $handle) = @_;
    my(@retlist,$line);

    croak "count must be > 0" unless $count > 0;
    $handle = Symbol::qualify($handle, (
caller()
)[0]);
    croak "need open filehandle" unless defined fileno($handle);

    push(@retlist, $line) while defined($line = <$handle>) && $count--;
    return @retlist;
}
#-----------------------------

# ^^PLEAC^^_12.6
#-----------------------------
$Logfile = "/tmp/mylog" unless defined $Logfile;
open(LF, ">>$Logfile")
    or die "can't append to $Logfile: $!";
select(((select(LF), $|=1))[0]);  # unbuffer LF
logmsg("startup");

sub logmsg {
    my $now = scalar gmtime;
    print LF "$0 $$ $now: @_\n"
        or die "write to $Logfile failed: $!";
}

END {
    logmsg("shutdown");
    close(LF)                     
        or die "close $Logfile failed: $!";
}
#-----------------------------
use sigtrap qw(die normal-signals error-signals);
#-----------------------------

# ^^PLEAC^^_12.7
#-----------------------------
#% perl -e 'for (@INC) { printf "%d %s\n", $i++, $_ }'
#0 /usr/local/perl/lib/i686-linux/5.004
#
#1 /usr/local/perl/lib
#
#2 /usr/local/perl/lib/site_perl/i686-linux
#
#3 /usr/local/perl/lib/site_perl
#
#4 .
#-----------------------------
# syntax for sh, bash, ksh, or zsh
#$ export PERL5LIB=$HOME/perllib

# syntax for csh or tcsh
#% setenv PERL5LIB ~/perllib
#-----------------------------
use lib "/projects/spectre/lib";
#-----------------------------
use FindBin;
use lib $FindBin::Bin;
#-----------------------------
use FindBin qw($Bin);
use lib "$Bin/../lib";
#-----------------------------

# ^^PLEAC^^_12.8
#-----------------------------
#% h2xs -XA -n Planets
#% h2xs -XA -n Astronomy::Orbits
#-----------------------------
package Astronomy::Orbits;
#-----------------------------
require Exporter;
require AutoLoader;
@ISA = qw(Exporter AutoLoader);
#-----------------------------
require Exporter;
require DynaLoader;
@ISA = qw(Exporter DynaLoader);
#-----------------------------
#% make dist
#-----------------------------

# ^^PLEAC^^_12.9
#-----------------------------
require Exporter;
require SelfLoader;
@ISA = qw(Exporter SelfLoader);
#
# other initialization or declarations here
#
#__DATA__
#sub abc { .... }
#sub def { .... }
#-----------------------------

# ^^PLEAC^^_12.10
#-----------------------------
#% h2xs -Xn Sample
#% cd Sample
#% perl Makefile.PL LIB=~/perllib
#% (edit Sample.pm)
#% make install
#-----------------------------

# ^^PLEAC^^_12.11
#-----------------------------
package FineTime;
use strict;
require Exporter;
use vars qw(@ISA @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT_OK = qw(time);

sub time() { ..... }  # TBA
#-----------------------------
use FineTime qw(time);
$start = time();
1 while print time() - $start, "\n";
#-----------------------------

# ^^PLEAC^^_12.12
#-----------------------------
sub even_only {
    my $n = shift;
    die "$n is not even" if $n & 1;  # one way to test
    #....
}
#-----------------------------
use Carp;
sub even_only {
    my $n = shift;
    croak "$n is not even" if $n % 2;  # here's another
    #....
}
#-----------------------------
use Carp;
sub even_only {
    my $n = shift;
    if ($n & 1) {         # test whether odd number
        carp "$n is not even, continuing";
        ++$n;
    }
    #....
}
#-----------------------------
carp "$n is not even, continuing" if $^W;
#-----------------------------

# ^^PLEAC^^_12.13
#-----------------------------
{
    no strict 'refs';
    $val  = ${ $packname . "::" . $varname };
    @vals = @{ $packname . "::" . $aryname };
    &{ $packname . "::" . $funcname }("args");
    ($packname . "::" . $funcname) -> ("args");
}
#-----------------------------
eval "package $packname; \$'$val = \$$varname"; # set $main'val
die if $@;
#-----------------------------
printf "log2  of 100 is %.2f\n", log2(100);
printf "log10 of 100 is %.2f\n", log10(100);
#-----------------------------
$packname = 'main';
for ($i = 2; $i < 1000; $i++) {
    $logN = log($i);
    eval "sub ${packname}::log$i { log(shift) / $logN }";
    die if $@;
}
#-----------------------------
$packname = 'main';
for ($i = 2; $i < 1000; $i++) {
    my $logN = log($i);
    no strict 'refs';
    *{"${packname}::log$i"} = sub { log(shift) / $logN };
}
#-----------------------------
*blue       = \&Colors::blue;
*main::blue = \&Colors::azure;
#-----------------------------

# ^^PLEAC^^_12.14
#-----------------------------
#Can't locate sys/syscall.ph in @INC (did you run h2ph?)
#
#(@INC contains: /usr/lib/perl5/i686-linux/5.00404 /usr/lib/perl5
#
#/usr/lib/perl5/site_perl/i686-linux /usr/lib/perl5/site_perl .)
#
#at some_program line 7.
#-----------------------------
#% cd /usr/include; h2ph sys/syscall.h
#-----------------------------
#% cd /usr/include; h2ph *.h */*.h
#-----------------------------
#% cd /usr/include; find . -name '*.h' -print | xargs h2ph
#-----------------------------
# file FineTime.pm
package main;
require 'sys/syscall.ph';
die "No SYS_gettimeofday in sys/syscall.ph"
    unless defined &SYS_gettimeofday;

package FineTime;
    use strict;
require Exporter;
use vars qw(@ISA @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT_OK = qw(time);

sub time() {
    my $tv = pack("LL", ());  # presize buffer to two longs
    syscall(&main::SYS_gettimeofday, $tv, undef) >= 0
        or die "gettimeofday: $!";
    my($seconds, $microseconds) = unpack("LL", $tv);
    return $seconds + ($microseconds / 1_000_000);
}

1;
#-----------------------------
# ^^INCLUDE^^ include/perl/ch12/jam
#-----------------------------
#% cat > tio.c <<EOF && cc tio.c && a.out
##include <sys/ioctl.h>
#main() { printf("%#08x\n", TIOCSTI); }
#EOF
#0x005412
#-----------------------------
# ^^INCLUDE^^ include/perl/ch12/winsz
#-----------------------------

# ^^PLEAC^^_12.15
#-----------------------------
#% perl Makefile.PL
#% make
#-----------------------------
#% h2xs -cn FineTime
#-----------------------------
#% perl Makefile.PL
#-----------------------------
#'LIBS'      => [''],   # e.g., '-lm'
#-----------------------------
#'LIBS'      => ['-L/usr/redhat/lib -lrpm'],
#-----------------------------
#% perl Makefile.PL LIB=~/perllib
#-----------------------------
package FineTime;
use strict;
use vars qw($VERSION @ISA @EXPORT_OK);
require Exporter;
require DynaLoader;
@ISA = qw(Exporter DynaLoader);
@EXPORT_OK = qw(time);
$VERSION = '0.01';
bootstrap FineTime $VERSION;
1;
##-----------------------------
##include <unistd.h>
##include <sys/time.h>
##include "EXTERN.h"
##include "perl.h"
##include "XSUB.h"
#
#MODULE = FineTime           PACKAGE = FineTime
#
#double
#time()
#    CODE:
#        struct timeval tv;
#        gettimeofday(&tv,0);
#        RETVAL = tv.tv_sec + ((double) tv.tv_usec) / 1000000;
#    OUTPUT:
#        RETVAL
#-----------------------------
#% make install
#mkdir ./blib/lib/auto/FineTime
#cp FineTime.pm ./blib/lib/FineTime.pm
#/usr/local/bin/perl -I/usr/lib/perl5/i686-linux/5.00403  -I/usr/lib/perl5
#/usr/lib/perl5/ExtUtils/xsubpp -typemap 
#    /usr/lib/perl5/ExtUtils/typemap FineTime.xs
#FineTime.tc && mv FineTime.tc FineTime.ccc -c -Dbool=char -DHAS_BOOL 
#    -O2-DVERSION=\"0.01\" -DXS_VERSION=\"0.01\" -fpic 
#    -I/usr/lib/perl5/i686-linux/5.00403/CORE  
#FineTime.cRunning Mkbootstrap for FineTime ()
#chmod 644 FineTime.bs
#LD_RUN_PATH="" cc -o blib/arch/auto/FineTime/FineTime.so 
#    -shared -L/usr/local/lib FineTime.o
#chmod 755 blib/arch/auto/FineTime/FineTime.so
#cp FineTime.bs ./blib/arch/auto/FineTime/FineTime.bs
#chmod 644 blib/arch/auto/FineTime/FineTime.bs
#Installing /home/tchrist/perllib/i686-linux/./auto/FineTime/FineTime.so
#Installing /home/tchrist/perllib/i686-linux/./auto/FineTime/FineTime.bs
#Installing /home/tchrist/perllib/./FineTime.pm
#Writing /home/tchrist/perllib/i686-linux/auto/FineTime/.packlist
#Appending installation info to /home/tchrist/perllib/i686-linux/perllocal.pod
#-----------------------------
#% perl -I ~/perllib -MFineTime=time -le '1 while print time()' | head
#888177070.090978
#
#888177070.09132
#
#888177070.091389
#
#888177070.091453
#
#888177070.091515
#
#888177070.091577
#
#888177070.091639
#
#888177070.0917
#
#888177070.091763
#
#888177070.091864
#-----------------------------

# ^^PLEAC^^_12.16
#-----------------------------
#=head2 Discussion
#
#If we had a I<.h> file with function prototype declarations, we
#could include that, but since we're writing this one from scratch,
#we'll use the B<-c> flag to omit building code to translate any
#C<#define> symbols. The B<-n> flag says to create a module directory
#named I<FineTime/>, which will have the following files.
#-----------------------------
#=for troff
#.EQ
#log sub n (x) = { {log sub e (x)} over {log sub e (n)} }
#.EN
#-----------------------------
#=for later
#next if 1 .. ?^$?;
#s/^(.)/>$1/;
#s/(.{73})........*/$1<SNIP>/;
#
#=cut back to perl
#-----------------------------
#=begin comment
#
#if (!open(FILE, $file)) {
#    unless ($opt_q) {  #)
#        warn "$me: $file: $!\n";
#        $Errors++;
#    }
#    next FILE;
#}
#
#$total = 0;
#$matches = 0;
#
#=end comment
#-----------------------------

# ^^PLEAC^^_12.17
#-----------------------------
#% gunzip Some-Module-4.54.tar.gz
#% tar xf Some-Module-4.54
#% cd Some-Module-4.54
#% perl Makefile.PL
#% make
#% make test
#% make install
#-----------------------------
#% gunzip MD5-1.7.tar.gz
#% tar xf MD5-1.7.tar
#% cd MD5-1.7
#% perl Makefile.PL 
#Checking if your kit is complete...
#
#Looks good
#
#Writing Makefile for MD5
#
#% make
#mkdir ./blib
#
#mkdir ./blib/lib
#
#cp MD5.pm ./blib/lib/MD5.pm
#
#AutoSplitting MD5 (./blib/lib/auto/MD5)
#
#/usr/bin/perl -I/usr/local/lib/perl5/i386 ...
#
#...
#
#cp MD5.bs ./blib/arch/auto/MD5/MD5.bs
#
#chmod 644 ./blib/arch/auto/MD5/MD5.bsmkdir ./blib/man3
#
#Manifying ./blib/man3/MD5.3
#
#% make test
#PERL_DL_NONLAZY=1 /usr/bin/perl -I./blib/arch -I./blib/lib
#
#-I/usr/local/lib/perl5/i386-freebsd/5.00404 -I/usr/local/lib/perl5 test.pl
#
#1..14
#
#ok 1
#
#ok 2
#
#...
#
#ok 13
#
#ok 14
#
#% sudo make install
#Password:
#
#Installing /usr/local/lib/perl5/site_perl/i386-freebsd/./auto/MD5/
#
#    MD5.so
#
#Installing /usr/local/lib/perl5/site_perl/i386-freebsd/./auto/MD5/
#
#    MD5.bs
#
#Installing /usr/local/lib/perl5/site_perl/./auto/MD5/autosplit.ix
#
#Installing /usr/local/lib/perl5/site_perl/./MD5.pm
#
#Installing /usr/local/lib/perl5/man/man3/./MD5.3
#
#Writing /usr/local/lib/perl5/site_perl/i386-freebsd/auto/MD5/.packlist
#
#Appending installation info to /usr/local/lib/perl5/i386-freebsd/
#
#5.00404/perllocal.pod
#-----------------------------
# if you just want the modules installed in your own directory
#% perl Makefile.PL LIB=~/lib
#
# if you have your own a complete distribution
#% perl Makefile.PL PREFIX=~/perl5-private
#-----------------------------

# ^^PLEAC^^_12.18
#-----------------------------
package Some::Module;  # must live in Some/Module.pm

use strict;

require Exporter;
use vars       qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION     = 0.01;

@ISA         = qw(Exporter);
@EXPORT      = qw(&func1 &func2 &func4);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions
@EXPORT_OK   = qw($Var1 %Hashit &func3);

use vars qw($Var1 %Hashit);
# non-exported package globals go here
use vars      qw(@more $stuff);

# initialize package globals, first exported ones
$Var1   = '';
%Hashit = ();

# then the others (which are still accessible as $Some::Module::stuff)
$stuff  = '';
@more   = ();

# all file-scoped lexicals must be created before
# the functions below that use them.

# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();

# here's a file-private function as a closure,
# callable as &$priv_func.
my $priv_func = sub {
    # stuff goes here.
};

# make all your functions, whether exported or not;
# remember to put something interesting in the {} stubs
sub func1      { .... }    # no prototype
sub func2()    { .... }    # proto'd void
sub func3($$)  { .... }    # proto'd to 2 scalars

# this one isn't auto-exported, but could be called!
sub func4(\%)  { .... }    # proto'd to 1 hash ref

END { }       # module clean-up code here (global destructor)

1;
#-----------------------------

# ^^PLEAC^^_12.19
#-----------------------------
#% pmdesc
#-----------------------------
#FileHandle (2.00) - supply object methods for filehandles
#
#IO::File (1.06021) - supply object methods for filehandles
#
#IO::Select (1.10) - OO interface to the select system call
#
#IO::Socket (1.1603) - Object interface to socket communications
#
#...
#-----------------------------
#% pmdesc -v
#
#<<<Modules from /usr/lib/perl5/i686-linux/5.00404>>>
#
#
#FileHandle (2.00) - supply object methods for filehandles
#
#    ...
#-----------------------------
# ^^INCLUDE^^ include/perl/ch12/pmdesc
#-----------------------------

# ^^PLEAC^^_13.0
#-----------------------------
$object = {};                       # hash reference
bless($object, "Data::Encoder");    # bless $object into Data::Encoder class
bless($object);                     # bless $object into current package
#-----------------------------
$obj = [3,5];
print ref($obj), " ", $obj->[1], "\n";
bless($obj, "Human::Cannibal");
print ref($obj), " ", $obj->[1], "\n";

ARRAY 5

Human::Cannibal 5
#-----------------------------
$obj->{Stomach} = "Empty";   # directly accessing an object's contents
$obj->{NAME}    = "Thag";        # uppercase field name to make it stand out (optional)
#-----------------------------
$encoded = $object->encode("data");
#-----------------------------
$encoded = Data::Encoder->encode("data");
#-----------------------------
sub new {
    my $class = shift;
    my $self  = {};         # allocate new hash for object
    bless($self, $class);
    return $self;
}
#-----------------------------
$object = Class->new();
#-----------------------------
$object = Class::new("Class");
#-----------------------------
sub class_only_method {
    my $class = shift;
    die "class method called on object" if ref $class;
    # more code here
} 
#-----------------------------
sub instance_only_method {
    my $self = shift;
    die "instance method called on class" unless ref $self;
    # more code here
} 
#-----------------------------
$lector = new Human::Cannibal;
feed $lector "Zak";
move $lector "New York";
#-----------------------------
$lector = Human::Cannibal->
new();

$lector->feed("Zak");
$lector->move("New York");
#-----------------------------
printf STDERR "stuff here\n";
#-----------------------------
move $obj->{FIELD};                 # probably wrong
move $ary[$i];                      # probably wrong
#-----------------------------
$obj->move->{FIELD};                # Surprise!
$ary->move->[$i];                   # Surprise!
#-----------------------------
$obj->{FIELD}->
move()
;              # Nope, you wish
$ary[$i]->
move;
                     # Nope, you wish
#-----------------------------

# ^^PLEAC^^_13.1
#-----------------------------
sub new {
    my $class = shift;
    my $self  = { };
    bless($self, $class);
    return $self;
} 
#-----------------------------
sub new { bless( { }, shift ) }
#-----------------------------
sub new { bless({}) }
#-----------------------------
sub new {
    my $self = { };  # allocate anonymous hash
    bless($self);
    # init two sample attributes/data members/fields
    $self->{START} = time();  
    $self->{AGE}   = 0;
    return $self;
} 
#-----------------------------
sub new {
    my $classname  = shift;         # What class are we constructing?
    my $self      = {};             # Allocate new memory
    bless($self, $classname);       # Mark it of the right type
    $self->{START}  = 
time();
       # init data fields
    $self->{AGE}    = 
0;

    return $self;                   # And give it back
} 
#-----------------------------
sub new {
    my $classname  = shift;         # What class are we constructing?
    my $self      = {};             # Allocate new memory
    bless($self, $classname);       # Mark it of the right type
    $self->_init(@_);               # Call _init with remaining args
    return $self;
} 

# "private" method to initialize fields.  It always sets START to
# the current time, and AGE to 0.  If called with arguments, _init
# interprets them as key+value pairs to initialize the object with.
sub _init {
    my $self = shift;
    $self->{START} = 
time();

    $self->{AGE}   = 0;
    if (@_) {
        my %extra = @_;
        @$self{keys %extra} = values %extra;
    } 
} 
#-----------------------------

# ^^PLEAC^^_13.2
#-----------------------------
sub DESTROY {
    my $self = shift;
    printf("$self dying at %s\n", scalar localtime);
} 
#-----------------------------
$self->{WHATEVER} = $self;
#-----------------------------

# ^^PLEAC^^_13.3
#-----------------------------
sub get_name {
    my $self = shift;
    return $self->{NAME};
} 

sub set_name {
    my $self      = shift;
    $self->{NAME} = shift;
} 
#-----------------------------
sub name {
    my $self = shift;
    if (@_) { $self->{NAME} = shift } 
    return $self->{NAME};
} 
#-----------------------------
sub age {
    my $self = shift;
    my $prev = $self->{AGE};
    if (@_) { $self->{AGE} = shift } 
    return $prev;
} 
# sample call of get and set: happy birthday!
$obj->age( 1 + $obj->age );
#-----------------------------
$him = Person->
new()
;
$him->{NAME} = "Sylvester";
$him->{AGE}  = 23;
#-----------------------------
use Carp;
sub name {
    my $self = shift;
    return $self->{NAME} unless @_;
    local $_ = shift;
    croak "too many arguments" if @_;
    if ($^W) {
        /[^\s\w'-]/         && carp "funny characters in name"; #'
        /\d/                && carp "numbers in name";
        /\S+(\s+\S+)+/      || carp "prefer multiword name";
        /\S/                || carp "name is blank";
    } 
    s/(\w+)/\u\L$1/g;       # enforce capitalization
    $self->{NAME} = $_;
} 
#-----------------------------
package Person;

# this is the same as before...
sub new {
     my $that  = shift;
     my $class = ref($that) || $that;
     my $self = {
           NAME  => undef,
           AGE   => undef,
           PEERS => [],
    };
    bless($self, $class);
    return $self;
}

use Alias qw(attr);
use vars qw($NAME $AGE @PEERS);

sub name {
    my $self = attr shift;
    if (@_) { $NAME = shift; }
    return    $NAME;
};

sub age {
    my $self = attr shift;
    if (@_) { $AGE = shift; }
    return    $AGE;
}

sub peers {
    my $self = attr shift;
    if (@_) { @PEERS = @_; }
    return    @PEERS;
}

sub exclaim {
    my $self = attr shift;
    return sprintf "Hi, I'm %s, age %d, working with %s",
            $NAME, $AGE, join(", ", @PEERS);
}

sub happy_birthday {
    my $self = attr shift;
    return ++$AGE;
}
#-----------------------------

