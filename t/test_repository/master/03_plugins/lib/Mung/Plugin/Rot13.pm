package Mung::Plugin::Rot13;

use strict;
use warnings;

sub mung {
    my ($plaintext) = @_;

    $plaintext =~ tr/A-MN-Za-mn-z/N-ZA-Mn-za-m/;
    return $plaintext;
}

1;
