#! c:\perl\bin\perl.exe
#-------------------------------------------------------------------------
# Rip - RegRipper, CLI version
# Use this utility to run a plugins file or a single plugin against a Reg
# hive file.
# 
# Output goes to STDOUT
# Usage: see "_syntax()" function
#
# Change History
#   20130801 - added File::Spec support, for cross-platform compat.
#   20130716 - added 'push(@INC,$str);' line based on suggestion from
#              Hal Pomeranz to support Linux compatibility
#   20130425 - added alertMsg() functionality, updated to v2.8
#   20120506 - updated to v2.5 release
#   20110516 - added -s & -u options for TLN support
#   20090102 - updated code for relative path to plugins dir
#   20080419 - added '-g' switch (experimental)
#   20080412 - added '-c' switch
#   20260922 - added input validation, path traversal protection, security hardening
#
# copyright 2013 Quantum Analytics Research, LLC
# Author: H. Carvey, keydet89@yahoo.com
#
# This software is released via the GPL v3.0 license:
# http://www.gnu.org/licenses/gpl.html
#-------------------------------------------------------------------------
use strict;
use warnings;
use Parse::Win32Registry qw(:REG_);
use Getopt::Long;
use File::Spec;
use File::Basename qw(basename);
use Cwd qw(abs_path);

# Included to permit compiling via Perl2Exe
#perl2exe_include "Parse/Win32Registry.pm";
#perl2exe_include "Parse/Win32Registry/Key.pm";
#perl2exe_include "Parse/Win32Registry/Entry.pm";
#perl2exe_include "Parse/Win32Registry/Value.pm";
#perl2exe_include "Parse/Win32Registry/File.pm";
#perl2exe_include "Parse/Win32Registry/Win95/File.pm";
#perl2exe_include "Parse/Win32Registry/Win95/Key.pm";
#perl2exe_include "Encode.pm";
#perl2exe_include "Encode/Byte.pm";
#perl2exe_include "Encode/Unicode.pm";
#perl2exe_include "utf8.pm";
#perl2exe_include "unicore/Heavy.pl";
#perl2exe_include "unicore/To/Upper.pl";

my %config;
Getopt::Long::Configure("prefix_pattern=(-|\/)");
GetOptions(\%config,qw(reg|r=s file|f=s csv|c guess|g user|u=s sys|s=s plugin|p=s list|l help|?|h));

# Code updated 20090102
my @path;
my $str = $0;
($^O eq "MSWin32") ? (@path = split(/\\/,$0))
                   : (@path = split(/\//,$0));
$str =~ s/($path[scalar(@path) - 1])//;

# Suggested addition by Hal Pomeranz for compatibility with 
# Linux
#push(@INC,$str);

#my $plugindir = $str."plugins/";
my $plugindir = File::Spec->catfile("plugins");
#print "Plugins Dir = ".$plugindir."\n";
# End code update
my $VERSION = "2\.8_20130801";
my @alerts = ();

# Security: Validate and sanitize inputs early
validate_config(\%config);

if ($config{help} || !%config) {
	_syntax();
	exit;
}

#-------------------------------------------------------------
# 
#-------------------------------------------------------------
if ($config{list}) {
	my @plugins;
	opendir(my $dh, $plugindir) || die "Could not open $plugindir: $!\n";
	@plugins = readdir($dh);
	closedir($dh);

	my $count = 1; 
	print "Plugin,Version,Hive,Description\n" if ($config{csv});
	foreach my $p (@plugins) {
		next unless ($p =~ m/\.pl$/);
		my $pkg = (split(/\./,$p,2))[0];
#		$p = $plugindir.$p;
		$p = File::Spec->catfile($plugindir,$p);
		eval {
			require $p;
			my $hive    = $pkg->getHive();
			my $version = $pkg->getVersion();
			my $descr   = $pkg->getShortDescr();
			if ($config{csv}) {
				print $pkg.",".$version.",".$hive.",".$descr."\n";
			}
			else {
				print $count.". ".$pkg." v.".$version." [".$hive."]\n";
#				printf "%-20s %-10s %-10s\n",$pkg,$version,$hive;
				print  "   - ".$descr."\n\n";
				$count++;
			}
		};
		print "Error: $@\n" if ($@);
	}
	exit;
}

#-------------------------------------------------------------
# 
#-------------------------------------------------------------
if ($config{file}) {
# First, check that a hive file was identified, and that the path is
# correct
	my $hive = $config{reg};
	die "You must enter a hive file path/name.\n" if ($hive eq "");
	# Hive file validation done in validate_config()
	
	my %plugins = parsePluginsFile($config{file});
	if (%plugins) {
		logMsg("Parsed Plugins file.");
	}
	else {
		logMsg("Plugins file not parsed.");
		exit;
	}
	foreach my $i (sort {$a <=> $b} keys %plugins) {
		eval {
#			require "plugins/".$plugins{$i}."\.pl";
			my $plugin_file = File::Spec->catfile($plugindir,$plugins{$i}.".pl");
			require $plugin_file;
			$plugins{$i}->pluginmain($hive);
		};
		if ($@) {
			logMsg("Error in ".$plugins{$i}.": ".$@);
		}
		logMsg($plugins{$i}." complete.");
		rptMsg("-" x 40);
	}
	printAlerts();
}

#-------------------------------------------------------------
# 
#-------------------------------------------------------------
if ($config{reg} && $config{guess}) {
# Attempt to guess which kind of hive we have
	my $hive = $config{reg};
	die "You must enter a hive file path/name.\n" if ($hive eq "");
	# Hive file validation done in validate_config()
	
	my $reg;
	my $root_key;
	my %guess = guessHive($hive);
	
	foreach my $g (keys %guess) {
		::rptMsg(sprintf "%-8s = %-2s",$g,$guess{$g});
	}
}

#-------------------------------------------------------------
# 
#-------------------------------------------------------------
if ($config{plugin}) {
# First, check that a hive file was identified, and that the path is
# correct
	my $hive = $config{reg};
	die "You must enter a hive file path/name.\n" if ($hive eq "");
	# Hive file validation done in validate_config()
	
# check to see if the plugin exists
	my $plugin = $config{plugin};
#	my $pluginfile = $plugindir.$config{plugin}."\.pl";
	my $pluginfile = File::Spec->catfile($plugindir,$config{plugin}."\.pl");
	die $pluginfile." not found.\n" unless (-e $pluginfile && -f $pluginfile);
	
	eval {
		require $pluginfile;
		$plugin->pluginmain($hive);
	};
	if ($@) {
		logMsg("Error in ".$pluginfile.": ".$@);
	}	
	printAlerts();
}

#-------------------------------------------------------------
# validate_config()
# Validate and sanitize configuration inputs
#-------------------------------------------------------------
sub validate_config {
    my $cfg = shift;
    
    # Validate hive file path if provided
    if (exists $cfg->{reg} && defined $cfg->{reg} && $cfg->{reg} ne '') {
        $cfg->{reg} = sanitize_path($cfg->{reg});
        validate_hive_file($cfg->{reg});
    }
    
    # Validate plugin profile file if provided
    if (exists $cfg->{file} && defined $cfg->{file} && $cfg->{file} ne '') {
        $cfg->{file} = sanitize_plugin_profile($cfg->{file});
    }
    
    # Validate single plugin name if provided
    if (exists $cfg->{plugin} && defined $cfg->{plugin} && $cfg->{plugin} ne '') {
        $cfg->{plugin} = sanitize_plugin_name($cfg->{plugin});
    }
    
    # Validate system name for TLN (alphanumeric, dash, underscore only)
    if (exists $cfg->{sys} && defined $cfg->{sys} && $cfg->{sys} ne '') {
        $cfg->{sys} = sanitize_tln_field($cfg->{sys}, 'system name');
    }
    
    # Validate user name for TLN (alphanumeric, dash, underscore only)
    if (exists $cfg->{user} && defined $cfg->{user} && $cfg->{user} ne '') {
        $cfg->{user} = sanitize_tln_field($cfg->{user}, 'user name');
    }
}

#-------------------------------------------------------------
# sanitize_path()
# Prevent path traversal attacks
#-------------------------------------------------------------
sub sanitize_path {
    my $path = shift;
    
    # Remove null bytes
    $path =~ s/\0//g;
    
    # Get absolute path
    my $abs_path = eval { abs_path($path) } || $path;
    
    # Ensure path doesn't contain directory traversal attempts
    # after normalization (abs_path should resolve .. but we double-check)
    if ($abs_path =~ m/\.\./) {
        die "Invalid path: directory traversal detected\n";
    }
    
    return $abs_path;
}

#-------------------------------------------------------------
# validate_hive_file()
# Validate that hive file exists and has valid signature
#-------------------------------------------------------------
sub validate_hive_file {
    my $hive = shift;
    
    # Check file exists and is readable
    die "Hive file not found: $hive\n" unless (-e $hive);
    die "Hive file not readable: $hive\n" unless (-r $hive);
    die "Hive path is not a file: $hive\n" unless (-f $hive);
    
    # Check file size (prevent DoS with huge files)
    my $size = -s $hive;
    die "Hive file is empty: $hive\n" if ($size == 0);
    
    # Optional: Check for reasonable max size (1GB default)
    my $max_size = 1024 * 1024 * 1024; # 1GB
    die "Hive file too large (>1GB): $hive\n" if ($size > $max_size);
    
    # Validate registry hive signature (first 4 bytes should be 'regf')
    open(my $fh, '<:raw', $hive) or die "Cannot open hive file: $hive\n";
    my $header;
    read($fh, $header, 4);
    close($fh);
    
    unless ($header eq 'regf') {
        logMsg("Warning: File may not be a valid registry hive (missing 'regf' signature): $hive");
        # Don't die, just warn - some hives might have different signatures
    }
}

#-------------------------------------------------------------
# sanitize_plugin_profile()
# Validate plugin profile name (no path traversal)
#-------------------------------------------------------------
sub sanitize_plugin_profile {
    my $profile = shift;
    
    # Remove null bytes
    $profile =~ s/\0//g;
    
    # Only allow alphanumeric, dash, underscore
    $profile =~ s/[^a-zA-Z0-9_-]//g;
    
    # Prevent empty after sanitization
    die "Invalid plugin profile name\n" if ($profile eq '');
    
    # Verify profile file exists in plugins directory
    my $profile_file = File::Spec->catfile($plugindir, $profile);
    die "Plugin profile not found: $profile\n" unless (-e $profile_file && -f $profile_file);
    
    return $profile;
}

#-------------------------------------------------------------
# sanitize_plugin_name()
# Validate plugin module name (no path traversal)
#-------------------------------------------------------------
sub sanitize_plugin_name {
    my $plugin = shift;
    
    # Remove null bytes
    $plugin =~ s/\0//g;
    
    # Only allow alphanumeric, dash, underscore
    $plugin =~ s/[^a-zA-Z0-9_-]//g;
    
    # Prevent empty after sanitization
    die "Invalid plugin name\n" if ($plugin eq '');
    
    # Verify plugin file exists in plugins directory
    my $plugin_file = File::Spec->catfile($plugindir, $plugin . ".pl");
    die "Plugin not found: $plugin\n" unless (-e $plugin_file && -f $plugin_file);
    
    return $plugin;
}

#-------------------------------------------------------------
# sanitize_tln_field()
# Validate TLN system/user name fields
#-------------------------------------------------------------
sub sanitize_tln_field {
    my ($field, $field_name) = @_;
    
    # Remove null bytes
    $field =~ s/\0//g;
    
    # Only allow alphanumeric, dash, underscore, dot, space
    $field =~ s/[^a-zA-Z0-9_. -]//g;
    
    # Limit length
    $field = substr($field, 0, 64);
    
    return $field;
}

sub _syntax {
	print<< "EOT";
Rip v.$VERSION - CLI RegRipper tool	
Rip [-r Reg hive file] [-f plugin file] [-p plugin module] [-l] [-h]
Parse Windows Registry files, using either a single module, or a plugins file.

  -r Reg hive file...Registry hive file to parse
  -g ................Guess the hive file (experimental)
  -f [profile].......use the plugin file (default: plugins\\plugins)
  -p plugin module...use only this module
  -l ................list all plugins
  -c ................Output list in CSV format (use with -l)
  -s system name.....Server name (TLN support)
  -u username........User name (TLN support)
  -h.................Help (print this information)
  
Ex: C:\\>rip -r c:\\case\\system -f system
    C:\\>rip -r c:\\case\\ntuser.dat -p userassist
    C:\\>rip -l -c

All output goes to STDOUT; use redirection (ie, > or >>) to output to a file\.
  
copyright 2013 Quantum Analytics Research, LLC
EOT
}

#-------------------------------------------------------------
# 
#-------------------------------------------------------------
sub logMsg {
	print STDERR $_[0]."\n";
}

#-------------------------------------------------------------
# 
#-------------------------------------------------------------
sub rptMsg {
	binmode STDOUT,":utf8";
	if ($config{sys} || $config{user}) {
		my @vals = split(/\|/,$_[0],5);
		my $str = $vals[0]."|".$vals[1]."|".$config{sys}."|".$config{user}."|".$vals[4];
		print $str."\n";
	}
	else {
		print $_[0]."\n";
	}
}

#-------------------------------------------------------------
# 
#-------------------------------------------------------------
sub alertMsg {
	push(@alerts,$_[0]);
}

sub printAlerts {
	if (scalar(@alerts) > 0) {
#		print "\n";
#		print "Alerts\n";
#		print "-" x 40,"\n";
		foreach (@alerts) {
			print $_."\n";
		}
	}
}

#-------------------------------------------------------------
# parsePluginsFile()
# Parse the plugins file and get a list of plugins
#-------------------------------------------------------------
sub parsePluginsFile {
	my $file = $_[0];
	my %plugins;
# Parse a file containing a list of plugins
# Future versions of this tool may allow for the analyst to 
# choose different plugins files	
#	my $pluginfile = $plugindir.$file;
	my $pluginfile = File::Spec->catfile($plugindir,$file);
	if (-e $pluginfile && -f $pluginfile) {
		open(my $fh, '<', $pluginfile) or die "Cannot open plugin file: $pluginfile\n";
		my $count = 1;
		while(<$fh>) {
			chomp;
			next if ($_ =~ m/^#/ || $_ =~ m/^\s+$/);
#			next unless ($_ =~ m/\.pl$/);
			next if ($_ eq "");
			$_ =~ s/^\s+//;
			$_ =~ s/\s+$//;
			$plugins{$count++} = $_; 
		}
		close($fh);
		return %plugins;
	}
	else {
		return undef;
	}
}

#-------------------------------------------------------------
# guessHive()
# 
#-------------------------------------------------------------
sub guessHive {
	my $hive = shift;
	my $reg;
	my $root_key;
	my %guess;
	eval {
		$reg = Parse::Win32Registry->new($hive);
	  $root_key = $reg->get_root_key;
	};
	$guess{unknown} = 1 if ($@);
	
# Check for SAM
	eval {
		$guess{sam} = 1 if (my $key = $root_key->get_subkey("SAM\\Domains\\Account\\Users"));
	};
# Check for Software	
	eval {
		$guess{software} = 1 if ($root_key->get_subkey("Microsoft\\Windows\\CurrentVersion") &&
				$root_key->get_subkey("Microsoft\\Windows NT\\CurrentVersion"));
	};

# Check for System	
	eval {
		$guess{system} = 1 if ($root_key->get_subkey("MountedDevices") &&
				$root_key->get_subkey("Select"));
	};
	
# Check for Security	
	eval {
		$guess{security} = 1 if ($root_key->get_subkey("Policy\\Accounts") &&
				$root_key->get_subkey("Policy\\PolAdtEv"));
	};
# Check for NTUSER.DAT	
	eval {
		$guess{ntuser} = 1 if ($root_key->get_subkey("Software\\Microsoft\\Windows\\CurrentVersion"));
		
	};	
	
	return %guess;
}

#-------------------------------------------------------------
# getTime()
# Translate FILETIME object (2 DWORDS) to Unix time, to be passed
# to gmtime() or localtime()
#-------------------------------------------------------------
sub getTime($$) {
	my $lo = shift;
	my $hi = shift;
	my $t;

	if ($lo == 0 && $hi == 0) {
		$t = 0;
	} else {
		$lo -= 0xd53e8000;
		$hi -= 0x019db1de;
		$t = int($hi*429.4967296 + $lo/1e7);
	};
	$t = 0 if ($t < 0);
	return $t;
}