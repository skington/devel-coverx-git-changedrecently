package Mung;

use strict;
use warnings;
use parent 'Exporter';
our @EXPORT_OK;

sub _pull_in_plugin {
    my $keyword = shift;
    my $plugin_module = 'Mung::Plugin::' . ucfirst($keyword);
    eval "use $plugin_module";
    no strict 'refs';
    *{"Mung::$keyword"} = \&{"${plugin_module}::mung"};
    push @EXPORT_OK, $keyword;
}

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

_pull_in_plugin('rot13');

=head3 disemvowel

 In: $plaintext
 Out: $disemvoweled_text

Supplied with a plaintext, returns a version with vowels removed. This is still
possible to read, but much slower.

=cut

_pull_in_plugin('disemvowel');

=head3 windows

 In: $plaintext
 Out: $windows_file_text

Supplied with a plaintext, replaces every long or duplicate with a DOS-style
8.3 filename, optionally padded with ~ and numbers to disambiguate it.

=cut

_pull_in_plugin('windows');


1;
