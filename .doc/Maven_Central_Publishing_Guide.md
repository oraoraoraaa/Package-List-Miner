# Publishing Maven-Miner to Maven Central - Step-by-Step Guide

This guide explains how to publish the Maven-Miner Java package to Maven Central Repository.

## Prerequisites

### 1. Create Sonatype Account

1. Create a JIRA account at [Sonatype JIRA](https://issues.sonatype.org/secure/Signup!default.jspa)
2. Create a New Project ticket to claim your groupId (e.g., `com.higolab` or `io.github.yourusername`)
   - Go to: https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&pid=10134
   - Example ticket: https://issues.sonatype.org/browse/OSSRH-XXXXX
   - Wait for approval (usually 1-2 business days)

### 2. Install GPG

GPG is required to sign your artifacts.

**macOS:**

```bash
brew install gnupg
```

**Linux:**

```bash
sudo apt-get install gnupg
# or
sudo yum install gnupg
```

### 3. Generate GPG Key

```bash
# Generate a new key
gpg --gen-key

# Follow the prompts:
# - Use your real name
# - Use your email address
# - Set a passphrase (remember this!)

# List your keys
gpg --list-keys

# Publish your public key to key servers
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
gpg --keyserver keys.openpgp.org --send-keys YOUR_KEY_ID
```

### 4. Configure Maven Settings

Create or edit `~/.m2/settings.xml`:

```xml
<settings>
  <servers>
    <server>
      <id>ossrh</id>
      <username>your-sonatype-username</username>
      <password>your-sonatype-password</password>
    </server>
  </servers>

  <profiles>
    <profile>
      <id>ossrh</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <properties>
        <gpg.executable>gpg</gpg.executable>
        <gpg.passphrase>your-gpg-passphrase</gpg.passphrase>
      </properties>
    </profile>
  </profiles>
</settings>
```

**Security Tip:** Use Maven's password encryption for production:

```bash
# Encrypt your master password
mvn --encrypt-master-password

# Encrypt your Sonatype password
mvn --encrypt-password
```

## Before Publishing

### 1. Update pom.xml Metadata

The `pom.xml` must include:

- **Project Information:**

  ```xml
  <name>Maven Central Miner</name>
  <description>Complete Maven Central package miner using Maven Indexer</description>
  <url>https://github.com/yourusername/Package-List-Miner</url>
  ```

- **License:**

  ```xml
  <licenses>
    <license>
      <name>MIT License</name>
      <url>https://opensource.org/licenses/MIT</url>
    </license>
  </licenses>
  ```

- **Developers:**

  ```xml
  <developers>
    <developer>
      <id>yourusername</id>
      <name>Your Name</name>
      <email>your.email@example.com</email>
    </developer>
  </developers>
  ```

- **SCM (Source Control Management):**
  ```xml
  <scm>
    <connection>scm:git:git://github.com/yourusername/Package-List-Miner.git</connection>
    <developerConnection>scm:git:ssh://github.com:yourusername/Package-List-Miner.git</developerConnection>
    <url>https://github.com/yourusername/Package-List-Miner/tree/main</url>
  </scm>
  ```

### 2. Update Version

For releases, use proper semantic versioning (no -SNAPSHOT):

```xml
<version>1.0.1</version>
```

For snapshots (testing):

```xml
<version>1.0.2-SNAPSHOT</version>
```

## Publishing Process

### Option A: Deploy to Staging (Recommended for First-Time)

This allows you to review before final release.

```bash
cd Maven-Miner

# Clean and build
mvn clean

# Deploy to staging repository
mvn deploy
```

After deployment:

1. Login to [Nexus Repository Manager](https://s01.oss.sonatype.org/)
2. Go to "Staging Repositories"
3. Find your repository (usually at the bottom)
4. Click "Close" to validate the artifacts
5. If validation passes, click "Release" to publish

The package will be available on Maven Central within 10-30 minutes, fully synced in ~2 hours.

### Option B: Direct Release (Automated)

Configure automatic release in `pom.xml`:

```xml
<plugin>
  <groupId>org.sonatype.plugins</groupId>
  <artifactId>nexus-staging-maven-plugin</artifactId>
  <version>1.6.13</version>
  <extensions>true</extensions>
  <configuration>
    <serverId>ossrh</serverId>
    <nexusUrl>https://s01.oss.sonatype.org/</nexusUrl>
    <autoReleaseAfterClose>true</autoReleaseAfterClose>
  </configuration>
</plugin>
```

Then simply run:

```bash
mvn clean deploy
```

### Snapshot Deployment (Development Versions)

For testing versions:

1. Set version to `X.Y.Z-SNAPSHOT` in pom.xml
2. Run:
   ```bash
   mvn clean deploy
   ```

Snapshots are published immediately to: https://s01.oss.sonatype.org/content/repositories/snapshots/

## Verification

After publishing, verify your artifact:

1. **Maven Central Search:**
   - https://search.maven.org/
   - Search for your groupId:artifactId

2. **Maven Repository:**
   - https://mvnrepository.com/
   - Search for your artifact

3. **Direct URL:**
   - https://repo1.maven.org/maven2/com/higolab/maven-miner/

## Using Published Package

Users can add your package to their `pom.xml`:

```xml
<dependency>
    <groupId>com.higolab</groupId>
    <artifactId>maven-miner</artifactId>
    <version>1.0.1</version>
</dependency>
```

Or use with Gradle:

```gradle
dependencies {
    implementation 'com.higolab:maven-miner:1.0.1'
}
```

## Troubleshooting

### Common Issues

1. **Missing Required Metadata:**
   - Error: "Missing: javadoc jar, sources jar"
   - Solution: Ensure maven-javadoc-plugin and maven-source-plugin are configured

2. **Signature Verification Failed:**
   - Error: "PGP signature cannot be verified"
   - Solution: Ensure GPG key is published to key servers and passphrase is correct

3. **Validation Errors:**
   - Check the Nexus Repository Manager for specific validation errors
   - Common: missing POM elements, unsigned artifacts

4. **401 Unauthorized:**
   - Check your credentials in `~/.m2/settings.xml`
   - Verify your Sonatype JIRA account is active

### Tips

- Always test with SNAPSHOT versions first
- Keep your GPG keys backed up securely
- Use semantic versioning (major.minor.patch)
- Once released, a version cannot be changed (you must release a new version)
- Maven Central syncs are cached - it may take time to appear everywhere

## Additional Resources

- [Maven Central Publishing Guide](https://central.sonatype.org/publish/publish-guide/)
- [Requirements for Publishing](https://central.sonatype.org/publish/requirements/)
- [GPG Guide](https://central.sonatype.org/publish/requirements/gpg/)
- [Releasing to Maven Central](https://maven.apache.org/repository/guide-central-repository-upload.html)

## Quick Reference

```bash
# Build locally
mvn clean package

# Test installation locally
mvn clean install

# Deploy snapshot
mvn clean deploy

# Deploy release
mvn clean deploy -P release

# Skip tests (not recommended)
mvn clean deploy -DskipTests

# Sign and deploy
mvn clean deploy -Dgpg.passphrase=your-passphrase
```
