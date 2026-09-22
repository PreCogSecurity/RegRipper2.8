#!/usr/bin/perl
# Tests for samparse plugin
use strict;
use warnings;
use Test::More;
use Test::Exception;

# Load the plugin
require_ok('plugins/samparse.pl');

# Test configuration
subtest 'Configuration' => sub {
    my %config = samparse::getConfig();
    
    is($config{hive}, 'SAM', 'Hive is SAM');
    is($config{hivemask}, 2, 'Hivemask is 2');
    is($config{output}, 'report', 'Output is report');
    is($config{osmask}, 63, 'OS mask covers XP-Win8');
    is($config{hasShortDescr}, 1, 'Has short description');
    is($config{hasRefs}, 1, 'Has references');
    ok($config{version} > 20000000, 'Version is reasonable date');
};

# Test getShortDescr
subtest 'Short description' => sub {
    my $descr = samparse::getShortDescr();
    like($descr, qr/Parse SAM/, 'Description mentions parsing SAM');
    like($descr, qr/user.*group|membership/, 'Description mentions user/group membership');
};

# Test getHive
subtest 'Get hive' => sub {
    is(samparse::getHive(), 'SAM', 'getHive returns SAM');
};

# Test getVersion
subtest 'Get version' => sub {
    my $version = samparse::getVersion();
    ok($version > 20000000, 'Version is a reasonable date');
    is($version, 20160203, 'Version matches expected');
};

# Test getRefs
subtest 'References' => sub {
    my %refs = samparse::getRefs();
    ok(exists $refs{'Well-known SIDs'}, 'Has Well-known SIDs reference');
    like($refs{'Well-known SIDs'}, qr/microsoft\.com/, 'Reference is Microsoft URL');
};

# Test _translateSID function (internal)
subtest 'SID translation' => sub {
    # Test 12-byte SID (S-1-5-21-...)
    my $sid12 = pack('C', 1) . pack('C', 1) . pack('H*', '000000000005') . pack('V', 21) . pack('V', 1000);
    my $result = samparse::_translateSID($sid12);
    like($result, qr/^S-1-5-21-\d+-\d+$/, '12-byte SID translates correctly');
    
    # Test 28-byte SID (with 4 sub-authorities)
    my $sid28 = pack('C', 1) . pack('C', 1) . pack('H*', '000000000005') . 
                pack('V4', 21, 1000, 2000, 3000) . pack('V', 500);
    $result = samparse::_translateSID($sid28);
    like($result, qr/^S-1-5-21-\d+-\d+-\d+-\d+-\d+$/, '28-byte SID translates correctly');
    
    # Test short SID
    my $sid_short = 'short';
    $result = samparse::_translateSID($sid_short);
    is($result, 'SID less than 12 bytes', 'Short SID handled correctly');
};

# Test _uniToAscii function (internal)
subtest 'Unicode to ASCII conversion' => sub {
    my $unicode = "H\0e\0l\0l\0o\0";
    my $result = samparse::_uniToAscii($unicode);
    is($result, 'Hello', 'Unicode string converted correctly');
    
    my $empty = "";
    $result = samparse::_uniToAscii($empty);
    is($result, '', 'Empty string handled correctly');
};

# Test parseV function (internal)
subtest 'parseV function' => sub {
    # Create a minimal V value structure
    # This is a simplified test since we don't have real registry data
    my $v_data = pack('V*', 0, 0xbc, 0, 0, 0, 0, 0, 0, 0, 0, 0) . ("\0" x 100);
    my %result = samparse::parseV($v_data);
    
    # Should not crash and should return a hash
    ok(defined $result{type}, 'parseV returns type');
    ok(defined $result{name}, 'parseV returns name');
};

# Test parseF function (internal)
subtest 'parseF function' => sub {
    # Minimal F value (68 bytes)
    my $f_data = "\0" x 68;
    my %result = samparse::parseF($f_data);
    
    ok(exists $result{last_login_date}, 'parseF returns last_login_date');
    ok(exists $result{pwd_reset_date}, 'parseF returns pwd_reset_date');
    ok(exists $result{acct_exp_date}, 'parseF returns acct_exp_date');
    ok(exists $result{pwd_fail_date}, 'parseF returns pwd_fail_date');
    ok(exists $result{rid}, 'parseF returns rid');
    ok(exists $result{acb_flags}, 'parseF returns acb_flags');
    ok(exists $result{failed_count}, 'parseF returns failed_count');
    ok(exists $result{login_count}, 'parseF returns login_count');
};

# Test parseC function (internal)
subtest 'parseC function' => sub {
    # Minimal C value (0x34 + data)
    my $c_data = "\0" x 0x34;
    my %result = samparse::parseC($c_data);
    
    ok(exists $result{group_name}, 'parseC returns group_name');
    ok(exists $result{comment}, 'parseC returns comment');
    ok(exists $result{num_users}, 'parseC returns num_users');
};

done_testing();