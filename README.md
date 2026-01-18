# Package-List-Miner

Automated data mining scripts for extracting complete package lists from major software ecosystem registries. Each miner fetches package metadata including names, authors, homepage urls, and repository urls. All miners output in the same csv format so that later-on scripts can easily operate on all of them with one input format standard.

## Supported Ecosystems

### 🦀 Crates (Rust)

- **Source**: [crates.io database dump](https://static.crates.io/db-dump.tar.gz)
- **Method**: Downloads and parses the official PostgreSQL database dump
- **Data**: Direct access to complete crates.io database tables

### 📦 NPM (JavaScript/Node.js)

- **Source**: [NPM Replicate CouchDB API](https://replicate.npmjs.com/_all_docs)
- **Method**: Queries the replicate CouchDB instance for package names, then fetches metadata from [registry.npmjs.org](https://registry.npmjs.org)
- **Data**: Complete NPM registry package information

### 🐍 PyPI (Python)

- **Source**: [PyPI Simple Index](https://pypi.org/simple/) and [JSON API](https://pypi.org/pypi/{package}/json)
- **Method**: Scrapes the simple index for package names, then fetches detailed metadata via JSON API
- **Data**: Full PyPI package information including project URLs and classifiers

### 🔵 Go

- **Source**: [Go Module Index](https://index.golang.org/index) and [Go Proxy](https://proxy.golang.org)
- **Method**: Streams the module index, then queries the proxy for version and metadata
- **Data**: Complete Go module registry with version information

### ☕ Maven (Java)

- **Source**: [Maven Central Repository Index](https://repo1.maven.org/maven2/.index/)
- **Method**: Downloads Apache Maven Indexer files and parses POM files from [Maven Central](https://repo1.maven.org/maven2/)
- **Data**: Artifact metadata from Maven Central including groupId, artifactId, versions, and SCM info

### 🐘 PHP

- **Source**: [Packagist API](https://packagist.org/packages/list.json)
- **Method**: Fetches complete package list, then queries individual package endpoints
- **Data**: Composer/Packagist package metadata

### 💎 Ruby

- **Source**: [RubyGems API](https://rubygems.org/api/v1/gems/)
- **Method**: Downloads gem names from [rubygems.org/names](http://rubygems.org/names), then fetches gem details via API
- **Data**: Complete RubyGems package information

## Installation

### From PyPI (Recommended)

Each Python-based miner is available as a standalone package on PyPI:

- **Crates**: [`pip install crates-miner`](https://pypi.org/project/crates-miner/)
- **NPM**: [`pip install npm-miner`](https://pypi.org/project/npm-miner/)
- **PyPI**: [`pip install pypi-miner`](https://pypi.org/project/pypi-miner/)
- **Go**: [`pip install go-miner`](https://pypi.org/project/go-miner/)
- **PHP**: [`pip install php-miner`](https://pypi.org/project/php-miner/)
- **Ruby**: [`pip install ruby-miner`](https://pypi.org/project/ruby-miner/)

### From Source

Each miner has its own directory with a `setup.sh` script (Python miners) or build script (Maven miner):

```bash
cd <Miner-Name>/
./setup.sh  # For Python-based miners
# or
./build.sh  # For Maven miner
```

## Usage

### Using Installed Packages

After installing from PyPI, run the miner directly:

```bash
crates-miner  # For Crates.io
npm-miner     # For NPM
pypi-miner    # For PyPI
go-miner      # For Go
php-miner     # For PHP
ruby-miner    # For Ruby
```

### From Source

Run any miner from its directory:

```bash
cd <Miner-Name>/
python mine_<ecosystem>.py
# or for Maven:
./run.sh
```

Output CSV files are saved to `./Package-List/<Ecosystem>.csv` (in current directory when installed) or `../Package-List/<Ecosystem>.csv` (when run from source)

## Features

- **Resumable**: All miners support checkpoint/resume functionality
- **Parallel Processing**: Concurrent API requests for faster data collection
- **Error Handling**: Robust retry logic and rate limit management
- **Progress Tracking**: Real-time progress bars using tqdm
- **Data Quality**: Extracts repository URLs, licenses, and comprehensive metadata
