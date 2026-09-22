# RegRipper 2.8 - CPAN Dependencies
# This file declares all Perl module dependencies for RegRipper.
# Install with: cpanm --installdeps .

requires 'perl', '5.014';

# Core dependencies (included in Perl 5.14+)
requires 'strict', '0';
requires 'warnings', '0';
requires 'File::Spec', '3.40';
requires 'Getopt::Long', '2.40';
requires 'Encode', '2.60';

# Registry parsing - primary dependency
requires 'Parse::Win32Registry', '1.0';

# GUI dependencies (Windows only)
on 'develop' => sub {
    requires 'Win32::GUI', '1.14';
    requires 'Win32::API', '0.84';
};

# Testing dependencies
on 'test' => sub {
    requires 'Test::More', '1.001014';
    requires 'Test::Exception', '0.43';
    requires 'Test::MockModule', '0.13';
    requires 'Test::File', '1.44';
    requires 'Test::Dir', '1.014';
    requires 'File::Temp', '0.2304';
    requires 'Path::Tiny', '0.108';
};

# Linting/Code quality (development)
on 'develop' => sub {
    requires 'Perl::Critic', '1.140';
    requires 'Perl::Critic::Policy::Variables::ProhibitUnusedVariables', '0';
    requires 'Perl::Tidy', '20230701';
    requires 'Devel::Cover', '1.40';
};

# Optional: For building executables
on 'develop' => sub {
    requires 'PAR::Packer', '1.050';
};