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

is(
    disemvowel('Llanfairpwllgwyngyllgogerychwyrndrobwyllllantysiliogogogoch'),
    'Llnfrpllgngllggrchrndrbllllntslgggch',
    'Special rules apply to Welsh'
);
is(
    disemvowel('Yggdrasil lolz'),
    'Yggdrsl llz',
    'Welsh-busting characters detected'
);

done_testing();
