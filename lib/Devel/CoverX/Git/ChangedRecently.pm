package Devel::CoverX::Git::ChangedRecently;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::pushd qw(pushd);

=head1 NAME

Devel::CoverX::Git::ChangedRecently - only cover recent git changes

=head1 VERSION

This is version 0.001.

=cut

our $VERSION = '0.001';
$VERSION = eval $VERSION;

=head1 SYNOPSIS

 $ PERL5OPT=-MDevel::Cover prove --lib --recurse t
 $ restrict_coverage --branch master
 $ cover -silent -report html_basic

...and the report only concerns itself with files that changed since the
current branch was branched from master.

=head1 DESCRIPTION

In a large project, your test coverage won't be perfect, and often your main
priority is that I<new code> has good test coverage, even if the older code
suffers somewhat. This extension to Devel::Cover I<removes> all coverage
information from a Devel::Cover database that's irrelevent to the current
branch.

=cut

=head1 AUTHOR

Sam Kington <skington@cpan.org>

The source code for this module is hosted on GitHub
L<https://github.com/skington/devel-coverx-git-changedrecently> - this is
probably the best place to look for suggestions and feedback.

=head1 COPYRIGHT

Copyright (c) 2020 Sam Kington.

=head1 LICENSE

This library is free software and may be distributed under the same terms as
perl itself.

=cut

1;
