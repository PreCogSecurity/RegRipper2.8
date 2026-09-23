#!/usr/bin/perl
# Basic load tests for RegRipper core modules
use strict;
use warnings;
use Test::More;
use File::Spec;

# Test that main scripts compile
BEGIN {
    use_ok('File::Spec');
    use_ok('Getopt::Long');
    use_ok('Parse::Win32Registry');
}

# Test rip.pl compiles
SKIP: {
    skip "rip.pl not found", 1 unless -f 'rip.pl';
    my $output = `perl -c rip.pl 2>&1`;
    like($output, qr/syntax OK/, 'rip.pl compiles cleanly');
}

# Test rr.pl compiles
SKIP: {
    skip "rr.pl not found", 1 unless -f 'rr.pl';
    my $output = `perl -c rr.pl 2>&1`;
    like($output, qr/syntax OK/, 'rr.pl compiles cleanly');
}

# Test plugin directory exists
ok(-d 'plugins', 'plugins directory exists');

# Test that plugins compile
my @plugins = glob('plugins/*.pl');
plan tests => 4 + scalar(@plugins);

for my $plugin (@plugins) {
    my $output = `perl -c "$plugin" 2>&1`;
    like($output, qr/syntax OK/, "$plugin compiles cleanly");
}

done_testing();