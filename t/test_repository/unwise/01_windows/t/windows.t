#!/usr/bin/env perl

use strict;
use warnings;

use Mung qw(windows);

use Test::More;

is(
    windows('Hello world'), 'Hello world',
    q{Short words aren't affected},
);

is(windows('Antidisestablishmentarianism is a bad thing'),
    'ANTIDI~1.TXT is a bad thing',
    'Long words are shortened to Windows filenames');

is(
    windows(
          'Panglossian thought: All is for the best in'
        . ' the best of all possible worlds'
    ),
    'PANGLO~1.TXT THOUGH~1.TXT All is for the best in'
        . ' THE~1.TXT BEST~1.TXT of ALL~1.TXT possible worlds',
    'We also catch duplicates'
);

done_testing();
