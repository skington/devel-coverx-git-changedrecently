#!/usr/bin/env perl
# Test that we cover only the files that changed in a branch, and ignore
# other untouched files.

use strict;
use warnings;

use lib::abs;
use Capture::Tiny qw(capture);
use Cwd;
use Path::Class::Dir;
use File::Copy::Recursive;
use File::pushd;
use File::Spec;
use File::Temp;
use Test::More;

# Find out the source for the repository we're going to build up,
# before we start changing directories all over the place.
my $repository_source_root = lib::abs::path('test_repository');

# Set up a repository with those files in it.
our ($test_root, $repository_root);
subtest('Set up a repository', \&startup_repository);

# Run all the tests under Devel::Cover.
subtest('Run tests under Devel::Cover', \&test_run_all_tests);

done_testing();

# Before any tests, set up a repository to hold the code we're testing.

sub startup_repository {
    # Remember where our source files live, and create a new directory
    # for all of these tests.
    $test_root = File::Temp->newdir(
        TEMPLATE => 'devel-coverx-git-changedrecently-XXXXX',
        TMPDIR   => 1,
        CLEANUP  => 1,
    );
    my $root_dir = pushd($test_root);
    ok(mkdir('repository'), 'Create a repository directory');
    chdir('repository');
    $repository_root = Cwd::abs_path(Cwd::getcwd());
    git_ok('Create a new repository', 'init');

    # Add a bunch of commits in master. Apart from the support for plugins
    # (which is introduced prematurely, and in a dubious way), they're basically
    # sane.
    for (
        ['00_rot13'              => 'First steps: rot13'],
        ['01_disemvowel'         => 'Add support for disemvowelling'],
        ['02_trailing_line_feed' => 'Add trailing line feeds',],
        ['03_plugins'            => 'Add support for plugins']
        )
    {
        my ($subdir, $title) = @$_;
        _commit_files('master', $subdir, $title);
    }

    # Now create a branch and add some far more dubious commits. These are the
    # ones we'll be testing.
    git_ok('Create a new branch',       'branch',   'unwise');
    git_ok('Switch to that new branch', 'checkout', 'unwise');
    for (['00_welsh' => 'Cope with Welsh vowels'],
        ['01_windows' => 'Turn words into Windows filenames'])
    {
        my ($subdir, $title) = @$_;
        _commit_files('unwise', $subdir, $title);
    }
}

# Run all the tests, even those that haven't changed in this branch.

sub test_run_all_tests {
    # Create coverage directories for master and the branch.
    my %coverage_dir;
    my $dir = pushd($test_root);
    ok(mkdir('coverage'), 'Create a coverage directory');
    my $dir_coverage = pushd('coverage');
    my $coverage_dir = Path::Class::Dir->new($test_root)->subdir('coverage');
    ok(mkdir('all_tests_master'), 'Create a directory for master');
    ok(mkdir('all_tests_unwise'), 'Create a directory for the branch');
    for my $branch (qw(master unwise)) {
        $coverage_dir{$branch} = $coverage_dir->subdir("all_tests_$branch");
    }
    undef $dir_coverage;

    # Run tests for master and for the branch, and get coverage for each of
    # them. Need to do it this way rather than first running tests then
    # generating coverage, because Devel::Cover will look at the file in
    # question when generating reports, and if it's changed it will complain
    # that it doesn't know what to do, so we need to be in the right branch
    # when we generate coverage reports.
    my %coverage_report;
    my $dir_repository = pushd('repository');
    for my $branch (qw(master unwise)) {
        subtest(
            "Test and run coverage for $branch",
            sub {
                git_ok("Switch to $branch", 'checkout', $branch);
                local $ENV{HARNESS_PERL_SWITCHES}
                    = sprintf('-MDevel::Cover=-dir,%s',
                    $coverage_dir{$branch});
                system_ok('Run the tests', 'prove', '--lib', '--recurse',
                    't');
                local $ENV{HARNESS_PERL_SWITCHES} = '';

                $coverage_report{$branch} = system_ok(
                    'Generate coverage',
                    'cover', $coverage_dir{$branch}->subdir('cover_db'),
                    '-silent',
                    '-report', 'compilation',
                    map {+ '-coverage' =>  $_ }
                        qw(statement branch condition subroutine),
                );
            }
        );
    }

    # Check that the right files are there, and with the right values.
    # prove won't be in the list, because we used HARNESS_PERL_SWITCHES
    # rather than PERL5OPT, but the test files will be.
    my %line_by_leafname;
    my $re_ascii_art_line  = qr/^ [ -]+ $/xsm;
    for my $branch (qw(master unwise)) {
        my ($lines) = $coverage_report{$branch} =~ m{
            $re_ascii_art_line \n
            File [^\n]+ \n
            $re_ascii_art_line \n
            (.+) \n
            $re_ascii_art_line
        }xsm;
        while ($lines =~ m{
            ^
            (?: [.]{3} )?     # The file might be elided with a leading ...
            (?: .*? )         # Ignore all stuff before the
            ( [^/]+? )        # leafname, which doesn't include
            \s+               # spaces (which in this case will always be true)
            ( [^\n]+ )        # followed by the stats
        }xsmg)
        {
            $line_by_leafname{$branch}{$1} = $2;
        }
    }

    # The basic functionality is fine in each report.
    my $re_perfect_statement_coverage = qr/^ 100[.]0 /x;
    for my $leafname (qw(Mung.pm rot13.t Rot13.pm disemvowel.t)) {
        for my $branch (qw(master unwise)) {
            like(
                $line_by_leafname{$branch}{$leafname},
                $re_perfect_statement_coverage,
                "$branch has $leafname and statement coverage is perfect"
            );
        }
    }

    # We don't have windows.t or Windows.pm in the master report.
    for my $leafname (qw(windows.t Windows.pm)) {
        ok(
            exists $line_by_leafname{unwise}{$leafname},
            "The branch report mentions $leafname"
        );
        ok(
            !exists $line_by_leafname{master}{$leafname},
            "The master report does not mention $leafname"
        );
    }

    # windows.t has total statement coverage; Windows.pm and Disemvowel.pm
    # are lacking. Windows.pm is missing, amongst other things, coverage of
    # an entire subroutine; and the welsh algorithm in Disemvowel.pm is
    # at best haphazardly-tested.
    like(
        $line_by_leafname{unwise}{'windows.t'},
        $re_perfect_statement_coverage,
        'The test script for Windows is fine in the branch'
    );
    for my $leafname (qw(Windows.pm Disemvowel.pm)) {
        unlike(
            $line_by_leafname{unwise}{$leafname},
            $re_perfect_statement_coverage,
            "Significant coverage problems for $leafname in the branch"
        );
    }
}

sub _commit_files {
    my ($branch_name, $subdir, $title) = @_;

    subtest(
        $title => sub {
            my $repository_source_dir
                = Path::Class::Dir->new($repository_source_root)
                ->subdir($branch_name)->subdir($subdir);
            ok(
                File::Copy::Recursive::dircopy(
                    $repository_source_dir, $repository_root
                ),
                "Copy files needed from $subdir"
            );
            git_ok('Add all new files', 'add', $repository_root);
            git_ok('Commit these changes',
                'commit', '--all', '--message', $title);
        }
    );
}

sub git_ok {
    my ($title, @git_args) = @_;

    my ($stdout, $stderr, $exit_code) = capture { system('git', @git_args); };
    ok($exit_code == 0, $title)
        or diag sprintf(
        "When running git %s:\nSTDOUT:\n%s\n\nSTDERR:\n%s\n\n",
        join(' ', @git_args),
        $stdout, $stderr
        );
}

sub system_ok {
    my ($title, @arguments) = @_;

    my ($stdout, $stderr, $exit_code) = capture {
        system @arguments
    };
    is($exit_code, 0, $title) or do {
        if ($stderr) {
            diag "Failure: got this on STDERR:\n", $stderr, "\n\n";
            return;
        }
    };
    is($stderr, '', "$title: nothing to STDERR")
        or diag "Warning: got this on STDERR:\n", $stderr, "\n\n";
    return $stdout;
}

