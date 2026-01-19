# Maven Central Miner

A Java tool to mine and extract complete package lists from Maven Central repository.

## Installation

Requires:
- Java 11 or higher
- Maven

Build the project:

```bash
./build.sh
```

## Usage

```bash
./run.sh
```

Or run directly:

```bash
java -jar target/maven-miner-1.0.1-jar-with-dependencies.jar
```

## Data Source

- Maven Central Index: https://repo1.maven.org/maven2/.index/
- POM Files: https://repo1.maven.org/maven2/

## Output

**Location:** `../Package-List/Maven.csv`

**Format:** CSV file with columns:
- ID (sequential number)
- Platform (always "Maven")
- Name (groupId:artifactId format)
- Homepage URL
- Repository URL
