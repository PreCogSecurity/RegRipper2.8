#!/usr/bin/perl
# Tests for plugin structure and basic functionality
use strict;
use warnings;
use Test::More;
use File::Spec;
use File::Glob qw(bsd_glob);

my @plugins = bsd_glob('plugins/*.pl');
plan tests => scalar(@plugins) * 4;

for my $plugin (@plugins) {
    my ($name) = $plugin =~ m{plugins/([^/]+)\.pl$};
    
    subtest "Plugin: $name" => sub {
        # Test 1: Plugin compiles
        my $output = `perl -c "$plugin" 2>&1`;
        like($output, qr/syntax OK/, "$name compiles cleanly");
        
        # Test 2: Has package declaration matching filename
        open(my $fh, '<', $plugin) or die "Cannot read $plugin: $!";
        my $content = do { local $/; <$fh> };
        close($fh);
        
        like($content, qr/^package\s+\Q$name\E\s*;/m, "$name has correct package declaration");
        
        # Test 3: Has required subroutines
        my @required_subs = qw(getConfig getShortDescr getHive getVersion pluginmain);
        for my $sub (@required_subs) {
            like($content, qr/^sub\s+\Q$sub\E\s*\{/m, "$name has $sub subroutine");
        }
        
        # Test 4: Returns true (ends with 1;)
        like($content, qr/^1;\s*$/m, "$name returns true");
    };
}

done_testing();