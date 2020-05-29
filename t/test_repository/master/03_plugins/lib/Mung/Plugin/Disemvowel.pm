package Mung::Plugin::Disemvowel;

use strict;
use warnings;

sub mung {
    my ($plaintext) = @_;

    $plaintext =~ tr/aeiouAEIOU//d;
    return $plaintext;
}

1;
