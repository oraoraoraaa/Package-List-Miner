# Publishing Miners to PyPI - Step-by-Step Guide

This guide explains how to publish each miner package to PyPI individually.

## Prerequisites

1. **PyPI Account**: Create accounts on:
   - [PyPI](https://pypi.org/account/register/) (production)
   - [TestPyPI](https://test.pypi.org/account/register/) (testing)

2. **Install build tools**:

   ```bash
   pip install --upgrade pip build twine
   ```

3. **Configure PyPI credentials**: Create `~/.pypirc`:

   ```ini
   [distutils]
   index-servers =
       pypi
       testpypi

   [pypi]
   username = __token__
   password = pypi-YOUR-API-TOKEN-HERE

   [testpypi]
   username = __token__
   password = pypi-YOUR-TEST-API-TOKEN-HERE
   ```

   > **Note**: Use API tokens instead of passwords. Generate them in your PyPI account settings.

## Before Publishing

### 1. Update Package Metadata

For each miner, edit `pyproject.toml` to update:

- **Author information**:

  ```toml
  authors = [
      {name = "Your Name", email = "your.email@example.com"}
  ]
  ```

- **Repository URLs**:

  ```toml
  [project.urls]
  Homepage = "https://github.com/oraoraoraaa/Package-List-Miner"
  Repository = "https://github.com/oraoraoraaa/Package-List-Miner"
  Issues = "https://github.com/oraoraoraaa/Package-List-Miner/issues"
  ```

- **Version number** (when making updates):
  ```toml
  version = "1.0.1"  # Increment for each release
  ```

### 2. Ensure README.md Exists

Each miner directory should have its own `README.md` that describes:

- What the miner does
- How to use it
- Any special requirements or notes

You can copy and customize the main README.md for each miner.

## Publishing Process

### Option A: Publish to TestPyPI First (Recommended)

Test your package on TestPyPI before publishing to production PyPI.

#### For each miner (example with Crates-Miner):

```bash
# Navigate to the miner directory
cd Crates-Miner

# Clean previous builds
rm -rf dist/ build/ *.egg-info

# Build the package
python -m build

# Upload to TestPyPI
python -m twine upload --repository testpypi dist/*

# Test installation from TestPyPI
pip install --index-url https://test.pypi.org/simple/ crates-miner

# Test the command
crates-miner

# Uninstall test version
pip uninstall crates-miner
```

If everything works correctly, proceed to production:

```bash
# Upload to PyPI (production)
python -m twine upload dist/*
```

### Option B: Publish Directly to PyPI

```bash
# Navigate to the miner directory
cd Crates-Miner

# Clean previous builds
rm -rf dist/ build/ *.egg-info

# Build the package
python -m build

# Upload to PyPI
python -m twine upload dist/*
```

## Publishing All Miners

To publish all miners at once, you can use this script:

```bash
#!/bin/bash

MINERS=(
    "Crates-Miner"
    "NPM-Miner"
    "PyPI-Miner"
    "Go-Miner"
    "PHP-Miner"
    "Ruby-Miner"
)

for miner in "${MINERS[@]}"; do
    echo "========================================="
    echo "Publishing $miner"
    echo "========================================="

    cd "$miner"

    # Clean previous builds
    rm -rf dist/ build/ *.egg-info

    # Build
    python -m build

    # Upload to TestPyPI (uncomment for testing)
    # python -m twine upload --repository testpypi dist/*

    # Upload to PyPI
    python -m twine upload dist/*

    cd ..

    echo ""
done

echo "All packages published!"
```

Save this as `publish_all.sh`, make it executable (`chmod +x publish_all.sh`), and run it.

## After Publishing

### Installation

Users can install any miner with:

```bash
pip install crates-miner
pip install npm-miner
pip install pypi-miner
pip install go-miner
pip install php-miner
pip install ruby-miner
```

### Usage

Each miner provides a command-line tool:

```bash
crates-miner    # Mine Crates.io packages
npm-miner       # Mine NPM packages
pypi-miner      # Mine PyPI packages
go-miner        # Mine Go modules
php-miner       # Mine PHP/Packagist packages
ruby-miner      # Mine RubyGems packages
```

## Updating Published Packages

When you need to update a package:

1. Make your code changes
2. Update the version number in `pyproject.toml`
3. Rebuild and republish:

```bash
cd <Miner-Directory>
rm -rf dist/ build/ *.egg-info
python -m build
python -m twine upload dist/*
```

## Troubleshooting

### "File already exists" error

PyPI doesn't allow overwriting existing versions. You must increment the version number in `pyproject.toml`.

### Import errors

If the package installs but imports fail, check:

- Package structure (ensure `__init__.py` exists)
- Module names match in `pyproject.toml` and directory structure

### "No module named X" when running

Ensure all dependencies are listed in `pyproject.toml` under `dependencies`.

### Testing locally before publishing

Install the package in development mode:

```bash
cd <Miner-Directory>
pip install -e .
```

This creates a symlink so changes are immediately reflected without reinstalling.

## Package Names on PyPI

The packages will be available as:

| Miner  | PyPI Name      | Command        |
| ------ | -------------- | -------------- |
| Crates | `crates-miner` | `crates-miner` |
| NPM    | `npm-miner`    | `npm-miner`    |
| PyPI   | `pypi-miner`   | `pypi-miner`   |
| Go     | `go-miner`     | `go-miner`     |
| PHP    | `php-miner`    | `php-miner`    |
| Ruby   | `ruby-miner`   | `ruby-miner`   |

## Best Practices

1. **Always test on TestPyPI first**
2. **Use semantic versioning** (MAJOR.MINOR.PATCH)
3. **Update CHANGELOG** or version notes for each release
4. **Tag releases in Git**: `git tag v1.0.0 && git push --tags`
5. **Keep README.md updated** with usage examples
6. **Use API tokens** instead of passwords for PyPI authentication

## Additional Resources

- [Python Packaging User Guide](https://packaging.python.org/)
- [PyPI Help](https://pypi.org/help/)
- [Twine Documentation](https://twine.readthedocs.io/)
- [Semantic Versioning](https://semver.org/)
