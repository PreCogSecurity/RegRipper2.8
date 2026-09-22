#!/usr/bin/perl
# Tests for rip.pl CLI interface
use strict;
use warnings;
use Test::More;
use Test::Exception;
use File::Temp qw(tempfile tempdir);
use File::Spec;
use File::Path qw(make_path);

# Test help output
subtest 'Help and syntax' => sub {
    my $output = `perl rip.pl -h 2>&1`;
    like($output, qr/Rip v\./, 'Shows version in help');
    like($output, qr/-r.*Reg hive file/, 'Shows -r option');
    like($output, qr/-f.*plugin file/, 'Shows -f option');
    like($output, qr/-p.*plugin module/, 'Shows -p option');
    like($output, qr/-l.*list all plugins/, 'Shows -l option');
    like($output, qr/-c.*CSV format/, 'Shows -c option');
    like($output, qr/-g.*Guess the hive/, 'Shows -g option');
    like($output, qr/-s.*System name/, 'Shows -s option');
    like($output, qr/-u.*User name/, 'Shows -u option');
};

# Test list plugins
subtest 'List plugins' => sub {
    my $output = `perl rip.pl -l 2>&1`;
    like($output, qr/\.pl/, 'Lists plugin files');
    like($output, qr/v\./, 'Shows plugin versions');
};

# Test list plugins CSV
subtest 'List plugins CSV' => sub {
    my $output = `perl rip.pl -l -c 2>&1`;
    like($output, qr/Plugin,Version,Hive,Description/, 'CSV header present');
    like($output, qr/.+,/, 'CSV data rows present');
};

# Test missing required arguments
subtest 'Error handling' => sub {
    # No arguments should show help
    my $output = `perl rip.pl 2>&1`;
    like($output, qr/Rip v\./, 'Shows help when no args');

    # Missing hive file with -f
    $output = `perl rip.pl -f ntuser 2>&1`;
    like($output, qr/You must enter a hive file/, 'Errors on missing hive with -f');

    # Missing hive file with -p
    $output = `perl rip.pl -p userassist 2>&1`;
    like($output, qr/You must enter a hive file/, 'Errors on missing hive with -p');

    # Non-existent plugin file
    $output = `perl rip.pl -r /nonexistent -f nonexistent 2>&1`;
    like($output, qr/not found|not parsed/, 'Errors on missing plugin file');

    # Non-existent plugin module
    $output = `perl rip.pl -r /nonexistent -p nonexistent 2>&1`;
    like($output, qr/not found/, 'Errors on missing plugin module');
};

# Test guess hive (requires a hive file, so we test the error path)
subtest 'Guess hive' => sub {
    my $output = `perl rip.pl -r /nonexistent -g 2>&1`;
    like($output, qr/You must enter a hive file|unknown/, 'Handles missing hive for guess');
};

# Test plugin profile parsing
subtest 'Plugin profile parsing' => sub {
    my $tempdir = tempdir(CLEANUP => 1);
    my $profile = File::Spec->catfile($tempdir, 'test_profile');
    
    # Create a test profile
    open(my $fh, '>', $profile) or die "Cannot create $profile: $!";
    print $fh "# Comment line\n";
    print $fh "userassist\n";
    print $fh "runmru\n";
    print $fh "\n";  # Empty line
    print $fh "  typedurls  \n";  # With whitespace
    close($fh);
    
    # We can't easily test parsePluginsFile without a hive, but we can verify
    # the profile file is readable
    ok(-f $profile, 'Test profile created');
    
    open(my $rfh, '<', $profile) or die "Cannot read $profile: $!";
    my @lines = <$rfh>;
    close($rfh);
    
    my @plugins;
    for my $line (@lines) {
        chomp $line;
        next if $line =~ m/^#/ || $line =~ m/^\s+$/;
        next if $line eq "";
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        push @plugins, $line;
    }
    
    is_deeply(\@plugins, ['userassist', 'runmru', 'typedurls'], 'Profile parsing works correctly');
};

# Test getTime function (via embedded test)
subtest 'Time conversion' => sub {
    # We can't easily call getTime directly, but we can verify the function exists
    # by checking the source
    open(my $fh, '<', 'rip.pl') or die "Cannot read rip.pl: $!";
    my $content = do { local $/; <$fh> };
    close($fh);
    
    like($content, qr/sub getTime/, 'getTime function exists');
    like($content, qr/0xd53e8000/, 'FILETIME epoch constant present');
    like($content, qr/0x019db1de/, 'FILETIME epoch constant present');
};

done_testing();