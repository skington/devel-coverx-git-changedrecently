package Mung;

use strict;
use warnings;
use parent 'Exporter';
our @EXPORT_OK = qw(rot13 disemvowel);

=head1 NAME

Mung - Mung Until No Good

=head1 SYNOPSIS

 use Mung qw(rot13);
 
 my $uncleartext = rot13($plaintext);
 my $other_uncleartext = disemvowel($plaintext);

=head1 DESCRIPTION

A collection of utilities for munging text, e.g. for use by moderators who wish
a post to become more difficult to read without actually censoring it.

=head2 Provided functions

=head3 rot13

 In: $plaintext
 Out: $rot13_text

Supplied with a plaintext, returns the rot13 version - with all letters shifted
13 places to the right in the alphabet. This is a lossless, reversible
transformation: calling rot13 on the $rot13_text will result in $plaintext
again.

=cut

sub rot13 {
    my ($plaintext) = @_;

    $plaintext =~ tr/A-MN-Za-mn-z/N-ZA-Mn-za-m/;
    return $plaintext;
}

=head3 disemvowel

 In: $plaintext
 Out: $disemvoweled_text

Supplied with a plaintext, returns a version with vowels removed. This is still
possible to read, but much slower.

=cut

sub disemvowel {
    my ($plaintext) = @_;
    
    $plaintext =~ tr/aeiouAEIOU//d;
    return $plaintext;
}

1;