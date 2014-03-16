[![Build Status](https://travis-ci.org/mruby/mgem-list.png?branch=master)](https://travis-ci.org/mruby/mgem-list)
mgem-list
=========

A list of all GEMs for mruby to be managed by mgem

# Contribute

If you want to add your own mruby GEM to this list please
create a pull request with your GEM details.

## Example

Every GEM file is based on YAML:

```
name: mruby-gem-name
description: This is the description of this GEM
author: Author Name
website: https://this.is/the/address/to/the/gem
protocol: git
repository: https://github.com/the/address/to/the/gem.git
```

## Guidlines

When creating a new GEM please consider:

* the name should express the functionality of the GEM clearly
* words should be separated by using dash (-)
* don't use *under_score* and *PascalCaseas*
* prefix should be *mruby-*
* if it's an executable, prefix should be *mruby-bin-*
