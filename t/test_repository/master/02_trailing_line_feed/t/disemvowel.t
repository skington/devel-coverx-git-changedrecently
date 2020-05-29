#!/usr/bin/env perl

use strict;
use warnings;

use Mung qw(disemvowel);

use Test::More;

is(
    disemvowel('WTFBBQ'), 'WTFBBQ',
    'Disemvowelling a phrase without vowels does nothing'
);

is(
    disemvowel(
        q{Your mother shags for bricks to build your sister's brothel}),
    q{Yr mthr shgs fr brcks t bld yr sstr's brthl},
    'Offensive speech is made more difficult to read'
);

done_testing();
