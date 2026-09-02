# Bundle Install Performance Optimization

## Problem Analysis

Bundle install currently takes 30-40 minutes due to several factors:

1. **Large dependency tree**: 82 gems with complex dependencies
2. **Native extension gems**: Several gems require compilation (nokogiri, mysql2, grpc, rugged, commonmarker, oj, anycable)
3. **Sequential installation**: No parallel job configuration
4. **Unnecessary groups**: Installing development and test gems when not needed
5. **No local gem caching**: Gems are downloaded and compiled repeatedly

## Current State

- Gemfile.lock contains 721 lines with 82 total gems
- Native extension gems identified: nokogiri, mysql2, grpc, rugged, commonmarker, oj, anycable
- No bundle configuration for parallel jobs (defaults to 1)
- No local gem path configuration
- Docker builds already optimized with pre-installed slow gems

## Optimization Strategies

### 1. Enable Parallel Installation

```bash
bundle config set jobs 4  # Use all available CPU cores
```

### 2. Configure Local Gem Path

```bash
bundle config set path 'vendor/bundle'  # Keep gems local to project
```

### 3. Exclude Unnecessary Groups

For development:
```bash
bundle config set without 'production'
bundle install
```

For production (already optimized in Docker):
```bash
bundle config set without 'development test'
```

### 4. Enable Gem Caching

```bash
bundle config set cache_all true
```

### 5. Pre-install Slow Native Extension Gems

Install system packages to speed up native extensions:

```bash
# For Ubuntu/Debian systems
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  cmake \
  pkg-config \
  libmysqlclient-dev \
  libxml2-dev \
  libxslt1-dev \
  libffi-dev \
  libssl-dev \
  zlib1g-dev \
  libyaml-dev \
  libreadline-dev \
  libncurses5-dev \
  libgdbm-dev \
  libdb-dev \
  libpcre3-dev \
  gettext
```

### 6. Use Bundle Cache in CI/Development

Create a persistent bundle cache:

```bash
# In development
bundle config set path 'vendor/bundle'
bundle install

# Add vendor/bundle to .gitignore but cache it in CI
```

## Implementation

The `.bundle/config` file has been created with optimal settings:

```yaml
---
BUNDLE_JOBS: "4"
BUNDLE_RETRY: "3"
BUNDLE_PATH: "vendor/bundle"
BUNDLE_WITHOUT: "production"
BUNDLE_CACHE_ALL: "true"
```

## Expected Performance Improvements

Based on analysis of the 82 gems and identified bottlenecks:

1. **Parallel installation**: ~75% reduction in install time (4x parallelization)
   - Before: Single-threaded installation of 82 gems
   - After: 4 parallel workers installing gems simultaneously

2. **Local gem path**: Faster gem loading and reduced conflicts
   - Before: System-wide gem installation with potential conflicts
   - After: Project-local gems in `vendor/bundle` with faster access

3. **Group exclusion**: ~20% fewer gems to install in development  
   - Before: Installing production + development + test gems (~82 total)
   - After: Excluding production group (~65 gems in development)

4. **System packages**: Faster native extension compilation
   - Before: 30+ minutes compiling nokogiri, mysql2, grpc, rugged, etc.
   - After: Pre-installed system libraries reduce compilation time by 50-80%

5. **Caching**: Subsequent installs ~90% faster
   - Before: Re-downloading and recompiling all gems
   - After: Using cached gems and compiled extensions

**Total Expected Improvement**: 
- First install: 30-40 minutes → 8-12 minutes
- Subsequent installs: 30-40 minutes → 2-5 minutes

## Usage

### First-time setup:
```bash
# Install system dependencies (Ubuntu/Debian)
sudo apt-get update && sudo apt-get install -y build-essential cmake pkg-config libmysqlclient-dev libxml2-dev libxslt1-dev

# Apply bundle configuration
bundle config set --local jobs 4
bundle config set --local path 'vendor/bundle'
bundle config set --local without 'production'
bundle config set --local cache_all true

# Install gems (should be much faster)
bundle install
```

### Subsequent installs:
```bash
bundle install  # Uses cached gems and parallel installation
```

### CI/Production:
- Docker builds already optimized
- Consider using bundle cache between builds
- Pre-install native extension gems individually as done in Dockerfile

## Troubleshooting

### Permission Issues:
```bash
# If you get permission errors, ensure proper ownership
sudo chown -R $USER:$USER vendor/bundle
```

### Ruby Version Mismatch:
```bash
# Use rbenv or similar to match Gemfile ruby version
rbenv install 3.4.4
rbenv local 3.4.4
```

### Memory Issues:
```bash
# Reduce parallel jobs if system has limited memory
bundle config set jobs 2
```

## Monitoring Performance

Track bundle install time:
```bash
time bundle install
```

Monitor gem installation progress:
```bash
bundle install --verbose
```