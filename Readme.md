# Brew Bundle

Bundler for non-Ruby dependencies from Homebrew

[![Code Climate](https://codeclimate.com/github/Homebrew/homebrew-bundle/badges/gpa.svg)](https://codeclimate.com/github/Homebrew/homebrew-bundle)
[![Coverage Status](https://coveralls.io/repos/Homebrew/homebrew-bundle/badge.svg)](https://coveralls.io/r/Homebrew/homebrew-bundle)
[![Build Status](https://travis-ci.org/Homebrew/homebrew-bundle.svg)](https://travis-ci.org/Homebrew/homebrew-bundle)

## Requirements

[Homebrew](http://github.com/Homebrew/homebrew) or [Linuxbrew](https://github.com/homebrew/linuxbrew) are used for installing the dependencies.
Linuxbrew is a fork of Homebrew for Linux, while Homebrew only works on Mac OS X.
This tool is primarily developed for use with Homebrew on Mac OS X but should work with Linuxbrew on Linux, too.

[brew tap](https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/brew-tap.md) is new feature in Homebrew 0.9, adds more GitHub repos to the list of available formulae.

[Homebrew Cask](http://github.com/caskroom/homebrew-cask) is optional and used for installing Mac applications.

## Install

You can install as a Homebrew tap:

    $ brew tap Homebrew/bundle

## Usage

Create a `Brewfile` in the root of your project:

    $ touch Brewfile

Then list your Homebrew based dependencies in your `Brewfile`:

    cask_args appdir: '/Applications'
    tap 'caskroom/cask'
    tap 'telemachus/brew', 'https://telemachus@bitbucket.org/telemachus/brew.git'
    brew 'emacs', args: ['with-cocoa', 'with-gnutls']
    brew 'redis', restart_service: true
    brew 'mongodb'
    brew 'sphinx'
    brew 'imagemagick'
    brew 'mysql'
    cask 'google-chrome'
    cask 'java' unless system '/usr/libexec/java_home --failfast'
    cask 'firefox', args: { appdir: '/Applications' }

You can then easily install all of the dependencies with one of the following commands:

    $ brew bundle

If a dependency is already installed and there is an update available it will be upgraded.

### Dump

You can create a `Brewfile` from all the existing Homebrew packages you have installed with:

    $ brew bundle dump

The `--force` option will allow an existing `Brewfile` to be overwritten as well.

### Cleanup

You can also use `Brewfile` as a whitelist. It's useful for maintainers/testers who regularly install lots of formulae. To uninstall all Homebrew formulae not listed in `Brewfile`:

    $ brew bundle cleanup

Unless the `--force` option is passed, formulae will be listed rather than actually uninstalled.

### Check

You can check there's anything to install/upgrade in the `Brewfile` by running:

    $ brew bundle check

This provides a successful exit code if everything is up-to-date so is useful for scripting.

### Restarting services

You can choose whether `brew bundle` restarts a service every time it's run, or
only when the formula is installed or upgraded. In you `Brewfile`:
`Brewfile`:

    # Always restart myservice
    brew 'myservice', restart_service: true

    # Only restart when installing or upgrading myservice
    brew 'myservice', restart_service: :changed

## Note

Homebrew does not support installing specific versions of a library, only the most recent one so there is no good mechanism for storing installed versions in a .lock file.

If your software needs specific versions then perhaps you'll want to look at using [Vagrant](http://vagrantup.com/) to better match your development and production environments.

## Contributors

Over 10 different people have contributed to the project, you can see them all here: https://github.com/Homebrew/homebrew-bundle/graphs/contributors

## Development

Source hosted at [GitHub](http://github.com/Homebrew/homebrew-bundle).
Report Issues/Feature requests on [GitHub Issues](http://github.com/Homebrew/homebrew-bundle/issues).

Tests can be ran with `bundle && bundle exec rake spec`

### Note on Patches/Pull Requests

 * Fork the project.
 * Make your feature addition or bug fix.
 * Add tests for it. This is important so I don't break it in a future version unintentionally.
 * Add documentation if necessary.
 * Commit, do not change Rakefile or history.
 * Send a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2015 Homebrew maintainers and Andrew Nesbitt. See [LICENSE](https://github.com/Homebrew/homebrew-bundle/blob/master/LICENSE) for details.
