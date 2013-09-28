# Knife Annex

Knife plugin that implements git-annex hook backend for chef-vault.

 - [git-annex](http://git-annex.branchable.com/)
 - [git-annex hook](http://git-annex.branchable.com/special_remotes/hook/)
 - [chef-vault](https://github.com/Nordstrom/chef-vault/)


This plugin uses a data bag named `annex` to store
items encrypted by chef-vault for admin chef users (except the
`admin` user created by default) available as git-annex files.

This allows keeping shared secret files (such as access keys - think
Amazon Web Services - or passwords) out of Git repository, store them
securely encrypted, and still keep convenient git-based access.

## Installation

Add this line to your chef repo's Gemfile:

    gem 'knife-annex'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install knife-annex

## Usage

Configure the hook type for git-annex:

    $ git config annex.chef-vault-hook 'knife annex'

If you use Bundler with your chef repo, you may need this form:

    $ git config annex.chef-vault-hook 'bundle exec knife annex'

Then, initialise the special remote:

    $ git annex initremote chef-server type=hook hooktype=chef-vault encryption=none

If you're extra paranoid, you can have double encryption by specifying
`encryption=shared` in the special remote's options.

After that, you can use `chef-server` remote normally with
git-annex.

When your admin user list changes, you can rekey the data by
running:

    $ knife annex --rotate-keys

## Contributing

See the [CONTRIBUTING.md](CONTRIBUTING.md) file
