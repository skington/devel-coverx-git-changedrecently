package Mung::Plugin::Windows;

use strict;
use warnings;

sub mung {
    my ($plaintext) = @_;

    my @words = split(/\s+/, $plaintext);
    my (%seen_word_as, @new_words);
    word:
    for my $word (@words) {
        if ($word =~ m{ ^ [a-z]{1,8} (?: [.] [a-z]{1,3} )? $ }xi
            && !$seen_word_as{lc $word})
        {
            $seen_word_as{lc $word} = $word;
            push @new_words, $word;
            next word;
        }
        $word = substr($word, 0, 6);
        num_suffix:
        for my $num_suffix ('1'..'9', '0') {
            my $candidate_word = uc($word) . '~' . $num_suffix . '.TXT';
            if (!$seen_word_as{$candidate_word}) {
                $seen_word_as{lc $word} = $candidate_word;
                push @new_words, $candidate_word;
                next word;
            }
        }
        
        ### TODO: deal with more conflicts.
        ...
    }
    return join(' ', @new_words);
}

sub _extension_for_word {
    my ($word) = @_;

    if ($word =~ /^ (google|apple|facebook|amazon) $/xi || $word =~ /corp$/i) {
        return 'exe';
    } else {
        return 'txt';
    }
}

1;
