# RegRipper 2.8

[![CI](https://github.com/PreCogSecurity/RegRipper2.8/actions/workflows/ci.yml/badge.svg)](https://github.com/PreCogSecurity/RegRipper2.8/actions/workflows/ci.yml)
[![Perl Critic](https://github.com/PreCogSecurity/RegRipper2.8/actions/workflows/perlcritic.yml/badge.svg)](https://github.com/PreCogSecurity/RegRipper2.8/actions/workflows/perlcritic.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
[![Perl Version](https://img.shields.io/badge/perl-5.14%2B-green.svg)](https://www.perl.org/)

RegRipper is a Windows Registry analysis and forensics tool written in Perl. It parses Windows Registry hive files (NTUSER.DAT, SYSTEM, SOFTWARE, SAM, SECURITY) and extracts forensic artifacts through a plugin architecture.

## Features

- **Plugin Architecture**: 200+ plugins for extracting specific registry artifacts
- **Multiple Hive Support**: NTUSER.DAT, SYSTEM, SOFTWARE, SAM, SECURITY
- **CLI & GUI**: Command-line (`rip.pl`) and GUI (`rr.pl`) interfaces
- **TLN Output**: Timeline (TLN) format support for log2timeline/plaso integration
- **Cross-Platform**: Runs on Windows, Linux, and macOS with Perl
- **Extensible**: Easy to write custom plugins for new artifacts

## Quick Start

### Prerequisites

- Perl 5.14 or higher
- CPAN dependencies (see [Installation](#installation))

### Installation

```bash
# Clone the repository
git clone https://github.com/PreCogSecurity/RegRipper2.8.git
cd RegRipper2.8

# Install Perl dependencies
cpanm --installdeps .

# Or using cpan
cpan Parse::Win32Registry Getopt::Long File::Spec Win32::GUI
```

### Usage

#### Command Line Interface (rip.pl)

```bash
# List all available plugins
perl rip.pl -l

# List plugins in CSV format
perl rip.pl -l -c

# Run a specific plugin against a hive file
perl rip.pl -r /path/to/NTUSER.DAT -p userassist

# Run a plugin profile (collection of plugins) against a hive
perl rip.pl -r /path/to/SYSTEM -f system

# Guess hive type (experimental)
perl rip.pl -r /path/to/hive -g
```

**Options:**
| Option | Description |
|--------|-------------|
| `-r, --reg` | Registry hive file to parse |
| `-f, --file` | Plugin profile file (default: plugins/plugins) |
| `-p, --plugin` | Single plugin module to run |
| `-l, --list` | List all available plugins |
| `-c, --csv` | Output plugin list in CSV format (use with -l) |
| `-g, --guess` | Guess hive type (experimental) |
| `-s, --sys` | System name (for TLN output) |
| `-u, --user` | Username (for TLN output) |
| `-h, --help` | Show help |

#### GUI Interface (rr.pl)

```bash
# Launch GUI (Windows only, requires Win32::GUI)
perl rr.pl
```

### Plugin Profiles

Plugin profiles are text files in the `plugins/` directory that list plugins to run. Examples:
- `ntuser` - Plugins for NTUSER.DAT hives
- `system` - Plugins for SYSTEM hives
- `software` - Plugins for SOFTWARE hives
- `sam` - Plugins for SAM hives
- `security` - Plugins for SECURITY hives

## Architecture

```
RegRipper/
├── rip.pl              # CLI entry point
├── rr.pl               # GUI entry point (Windows)
├── plugins/            # Plugin directory (~200 plugins)
│   ├── *.pl           # Individual plugin modules
│   ├── ntuser         # NTUSER.DAT plugin profile
│   ├── system         # SYSTEM plugin profile
│   ├── software       # SOFTWARE plugin profile
│   ├── sam            # SAM plugin profile
│   └── security       # SECURITY plugin profile
├── t/                 # Test directory
├── cpanfile           # CPAN dependencies
├── .perlcriticrc      # Perl::Critic configuration
└── .github/workflows/ # CI/CD pipelines
```

### Plugin Structure

Each plugin is a Perl module with the following required subroutines:

```perl
package plugin_name;
use strict;

my %config = (
    hive          => "NTUSER",    # Target hive: NTUSER, SYSTEM, SOFTWARE, SAM, SECURITY
    hivemask      => 1,           # Bitmask for hive type
    output        => "report",    # Output type
    category      => "",          # Category for grouping
    osmask        => 63,          # OS bitmask (XP=1, Vista=2, Win7=4, Win8=8, Win10=16, Win11=32)
    hasShortDescr => 1,
    hasDescr      => 0,
    hasRefs       => 1,
    version       => 20240101,
);

sub getConfig { return %config }
sub getShortDescr { return "Short description" }
sub getDescr { return "Long description" }
sub getRefs { return %references_hash }
sub getHive { return $config{hive} }
sub getVersion { return $config{version} }

sub pluginmain {
    my ($class, $hive_path) = @_;
    # Plugin logic here
    # Use ::rptMsg() for report output
    # Use ::logMsg() for logging
    # Use ::alertMsg() for alerts
}
1;
```

## Development

### Running Tests

```bash
# Run all tests
prove -lr t/

# Run with verbose output
prove -lrv t/

# Run specific test file
prove -lv t/rip_pl.t
```

### Linting

```bash
# Install Perl::Critic
cpanm Perl::Critic

# Run linting
perlcritic --profile .perlcriticrc rip.pl rr.pl plugins/
```

### Adding a New Plugin

1. Create a new `.pl` file in `plugins/`
2. Follow the plugin structure above
3. Add the plugin to the appropriate profile file(s) in `plugins/`
4. Write tests in `t/plugins/`
5. Run tests and linting

## Security

- **Input Validation**: All file paths are validated before processing
- **Path Traversal Protection**: Uses `File::Spec` for safe path handling
- **No Arbitrary Code Execution**: Plugins are loaded from controlled directory only
- **Dependency Hygiene**: Pinned dependencies in `cpanfile`

See [SECURITY.md](SECURITY.md) for vulnerability reporting.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

RegRipper is released under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.

Original author: H. Carvey (keydet89@yahoo.com)
Maintained by: PreCog Security

## References

- [Windows Registry Forensics](https://github.com/keydet89/RegRipper)
- [Parse::Win32Registry](https://metacpan.org/pod/Parse::Win32Registry)
- [TLN Format Specification](https://github.com/log2timeline/plaso/wiki/TLN-format)