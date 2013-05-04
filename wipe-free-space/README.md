# wipe-free-space: a privacy utility

## Introduction

This Ruby gem consists of a simple
utility, called wipe-free-space,
which wipes free space on disk filesystems.
It processes a filesystem by temporarily filling
it with temporary files, thus overwriting disk blocks belonging to
deleted files.

### Requirements

* Ruby 2.
* Linux

Supporting Ruby 1.9.3 would actually be trivial.

Supporting other Unix variants would probably be easy.

## Installation

Simply install the gem:

    gem install wipe_free_space

This will install a program called wipe-free-space.
Run `wipe-free-space --help` to get a comprehensive usage
message.

## Usage

Wipe free space on all disk filesystems:

    wipe-free-space

Wipe free space on `/home` and `/usr/local` only:

    wipe-free-space /home /usr/local

Exclude any filesystem mounted on or under `/media` or `/mnt`:

    wipe-free-space --exclude /media --exclude /mnt

Leave 1% free on `/var/log`, 10<sup>7</sup> bytes
free on `/tmp`, and 100,200 bytes free on `/boot`:

    wipe-free-space --min-free /var/log:1% --min-free /tmp:1e7 --min-free /boot:100200

Omitting a mount point when using `--min-free` sets a default
for all filesystems.  For example, to
leave 1% free on `/var/log` and 2% free on all other filesystems:

    wipe-free-space --min-free /var/log:1% --min-free :2%

Suppress progress reports; report only error conditions:

    wipe-free-space --log-level warn

## Notes

The software performs only one pass, and
writes ASCII NUL characters rather than random data,
so an adversary with special hardware may be able to recover
your data.

No attempt is made to wipe metadata (such as inode tables).

## Tests

The gem comes with tests, but they don't exercise all
the program's functionality, and are currently specific
to the author's setup.
