# mgem-list

[![Build Status](https://travis-ci.org/mruby/mgem-list.png?branch=master)](https://travis-ci.org/mruby/mgem-list)

A list of all GEMs for mruby to be managed by mgem

# Contribute

If you want to add your own mruby GEM to this list please
create a pull request with your GEM details.

- [CONTRIBUTING.md](CONTRIBUTING.md)

## Example

Every GEM file is based on YAML:

```yaml
name: mruby-gem-name
description: This is the description of this GEM
author: Author Name
license: MIT
website: https://gem.example/the/address/to/the/gem
protocol: git
repository: https://gem.example/the/address/to/the/gem.git
branch: main # Need to set this if default branch is not "master"
```

## Guidelines

When creating a new GEM please consider:

- the name should express the functionality of the GEM clearly
- words should be separated by using dash (-)
- don't use `under_score` and `CamelCase`
- prefix should be `mruby-`
- if it's an executable, prefix should be _mruby-bin-_
