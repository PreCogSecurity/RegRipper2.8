# Contributing to RegRipper

Thank you for your interest in contributing to RegRipper! This document provides guidelines for contributing to the project.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/PreCogSecurity/RegRipper2.8/issues)
2. If not, create a new issue with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment (OS, Perl version, RegRipper version)
   - Sample hive file (if possible, or description of the hive type)

### Suggesting Enhancements

1. Check existing issues and discussions
2. Create a new issue with:
   - Clear description of the enhancement
   - Use case / motivation
   - Proposed implementation approach (if any)

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes following the guidelines below
4. Run tests and linting locally
5. Submit a pull request with:
   - Clear description of changes
   - Reference to related issue(s)
   - Screenshots (for GUI changes)

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/RegRipper2.8.git
cd RegRipper2.8

# Install dependencies
cpanm --installdeps .

# Run tests
prove -lr t/

# Run linting
perlcritic --profile .perlcriticrc rip.pl rr.pl plugins/
```

## Coding Standards

### Perl Style Guide

- Use `strict` and `warnings` in all files
- Follow Perl::Critic policies defined in `.perlcriticrc`
- Use 4-space indentation (no tabs)
- Maximum line length: 120 characters
- Use descriptive variable names
- Document all public subroutines with POD

### Plugin Development

Each plugin must:

1. Be placed in `plugins/` directory with `.pl` extension
2. Have a package name matching the filename (e.g., `plugin_name.pl` → `package plugin_name;`)
3. Implement required subroutines:
   - `getConfig()` - Returns configuration hash
   - `getShortDescr()` - Returns one-line description
   - `getDescr()` - Returns detailed description (optional)
   - `getRefs()` - Returns references hash (optional)
   - `getHive()` - Returns target hive type
   - `getVersion()` - Returns version date (YYYYMMDD)
   - `pluginmain($class, $hive_path)` - Main entry point
4. End with `1;`
5. Use `::rptMsg()` for report output
6. Use `::logMsg()` for logging
7. Use `::alertMsg()` for security alerts
8. Handle errors gracefully with `eval` blocks

### Configuration Hash

```perl
my %config = (
    hive          => "NTUSER",    # NTUSER, SYSTEM, SOFTWARE, SAM, SECURITY
    hivemask      => 1,           # Bitmask: NTUSER=1, SYSTEM=2, SOFTWARE=4, SAM=8, SECURITY=16
    output        => "report",    # Output type
    category      => "",          # Category for grouping
    osmask        => 63,          # OS bitmask (see below)
    hasShortDescr => 1,
    hasDescr      => 0,
    hasRefs       => 1,
    version       => 20240101,    # YYYYMMDD format
);
```

### OS Mask Values

| OS | Value |
|----|-------|
| Windows XP | 1 |
| Windows Vista | 2 |
| Windows 7 | 4 |
| Windows 8/8.1 | 8 |
| Windows 10 | 16 |
| Windows 11 | 32 |

Combine with bitwise OR (e.g., XP through Win11 = 1|2|4|8|16 = 31)

### Hive Mask Values

| Hive | Value |
|------|-------|
| NTUSER.DAT | 1 |
| SYSTEM | 2 |
| SOFTWARE | 4 |
| SAM | 8 |
| SECURITY | 16 |

### Adding Plugins to Profiles

After creating a plugin, add it to the appropriate profile file(s) in `plugins/`:
- `ntuser` - For NTUSER.DAT plugins
- `system` - For SYSTEM plugins
- `software` - For SOFTWARE plugins
- `sam` - For SAM plugins
- `security` - For SECURITY plugins

## Testing

### Writing Tests

1. Place tests in `t/` directory
2. Name test files descriptively: `feature_name.t`
3. Use `Test::More` and related modules
4. Test both success and failure paths
5. Mock external dependencies (registry hives, file system)

### Running Tests

```bash
# All tests
prove -lr t/

# Specific test file
prove -lv t/rip_pl.t

# With coverage
cover -test
```

## Security Considerations

- **Never** commit secrets, API keys, or credentials
- Validate all file paths using `File::Spec`
- Use `eval` blocks for plugin loading
- Sanitize all user inputs
- Report security issues privately to security@precogsecurity.com

## Documentation

- Update README.md for user-facing changes
- Update CHANGELOG.md with each release
- Add POD documentation to new plugins
- Update CONTRIBUTING.md if processes change

## Release Process

1. Update version in relevant files
2. Update CHANGELOG.md
3. Run full test suite
4. Run linting
5. Create release tag
6. Build executables (Windows)
7. Publish release notes

## Getting Help

- Open a GitHub Discussion for questions
- Check existing issues and PRs
- Review the [RegRipper documentation](https://github.com/keydet89/RegRipper)

## License

By contributing, you agree that your contributions will be licensed under the GPL v3.0, same as the project.