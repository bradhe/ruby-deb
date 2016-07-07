# Installing Ruby Sucks

Guys, let's talk. It's 2016. Somehow, installing Ruby is still :poop:. Using
RVM or rbenv in your production environments is a horrible idea. Why can't I
just install this from a f*@!ing deb package?

## Download and install Ruby 2.3.1 from a Deb package

```bash
$ curl https://s3.amazonaws.com/bradhe-packages/ruby-2.3.1.deb > ruby-2.3.1.deb
$ dpkg -i ./ruby-2.3.1.deb
```

## How it works

It's pretty straight forward.

1. Download, build, and install Ruby
1. Gather all the things that the Ruby install process installed.
1. Build a Debian package using [fpm](https://github.com/jordansissel/fpm).

## Using it

```bash
$ ./build.sh
# ... lots of spam
$ aws s3 cp ./ruby_2.3.1_amd64.deb s3://my-bucket/ruby-2.3.1-amd64.deb --acl public-read
```

Download it and install it on the relevant machine now.
