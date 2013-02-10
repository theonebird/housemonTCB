# Mac OSX

Setting up HouseMon on Mac OSX is very easy, since all the necessary pieces
are available via the [HomeBrew](http://mxcl.github.com/homebrew/) package
manager. Here are the steps, if you're starting from scratch:

    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

That's HomeBrew's way of getting started. Odd, but effective, and you only
ever have to do this once. After that, the "brew" command can be used for
*everything*, including updating HomeBrew itself (using "brew update").

## Node.js

To install Node.js and npm, type this command:

    brew install node

HomeBrew installs both Node.js and npm, but npm's default location is not so
convenient, because globally installed packages won't be found from the
command line as is. The solution is to edit your "~/.bash_profile" file and
add this line to it:

    PATH=/usr/local/share/npm/bin:$PATH

Then save, log out, and log back in and evertyhing will work perfectly.

## Redis

To install Redis, type this command:

    brew install redis

HomeBrew will finish with some suggestions on how to make Redis start up and
run in the background whenever you turn on your Mac. Very convenient, I can
definitely recommend following those instructions.

## HouseMon

The rest is  standard installation, as described in HouseMon's README file.
