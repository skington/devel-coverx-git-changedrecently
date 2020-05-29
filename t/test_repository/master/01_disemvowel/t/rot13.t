#!/usr/bin/env perl

use strict;
use warnings;

use Mung qw(rot13);

use Test::More;

is(
    rot13(rot13('Woo yay hoopla!')),
    'Woo yay hoopla!',
    'rot13 of rot13 is the plaintext again'
);
is(
    rot13('O Romeo, Romeo, wherefore art thou Romeo?'),
    'B Ebzrb, Ebzrb, jurersber neg gubh Ebzrb?',
    'rot13 behaves the same way as the rot13.com website'
);

done_testing();