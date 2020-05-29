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

my $repository_source_root = lib::abs::path('test_repository');
our ($test_root, $repository_root);
subtest('Set up a repository', \&startup_repository);

done_testing();

sub startup_repository {
    # Remember where our source files live, and create a new directory
    # for all of these tests.
    $test_root = File::Temp->newdir(
        TEMPLATE => 'devel-coverx-git-changedrecently-XXXXX',
        TMPDIR   => 1,
        CLEANUP  => 0, ### FIXME: remove after testing
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
                "Copy files needed from $subdir for $title"
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

