package Mung::Plugin::Disemvowel;

use strict;
use warnings;

sub mung {
    my ($plaintext) = @_;

    # Character frequencies in both languages:
    # English: e t a o i n s r h l d ...
    # Welsh:   a y n d r e i l o g h ...
    # Welsh doesn't have J (much), K, Q, V, X or Z, so any presence of those
    # letters makes this automatically non-Welsh.
    my $is_welsh;
    if ($plaintext =~ /[jkqvxz]/i) {
        $is_welsh = 0;
    } else {
        my %frequency_count;
        for my $letter ('a' .. 'z') {
            $frequency_count{$letter}
                = scalar(my @letters = ($plaintext =~ m/$letter/ig));
        }
        if ($frequency_count{y} > $frequency_count{e}) {
            $is_welsh = 1;
        } elsif ($frequency_count{d} > $frequency_count{t}) {
            $is_welsh = 1;
        } else {
            $is_welsh = 0;
        }
    }
    if ($is_welsh) {
        $plaintext =~ tr/aeiouAEIOUwyWY//d;
    } else {
        $plaintext =~ tr/aeiouAEIOU//d;
    }
    return $plaintext;
}

1;
