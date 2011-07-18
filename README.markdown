Sky Spy
=======
Perl scripts for monitoring network status on Sky Broadband routers.

Work in progress
----------------
This is still a work in progress and a little rough around the edges.
Documentation is lacking.

`download.pl` is not yet ready for mainstream use.

Rationale
---------
You would use Sky Spy if:

* you have issues with your Sky Broadband connection, and would like to
  diagnose the problem, or gather evidence to present to tech support.
* you would like to keep an eye on your network for some other reason.

It’s worth noting that, to get a really accurate log of what’s going on, the
machine running Sky Spy should be left on 24/7. If you aren’t happy with that,
you probably need look elsewhere.

Installing
----------
I’ve tried to make these scripts as simple to install with as few hard
requirements as possible, and am testing them with the default
Mac-OS-Snow-Leopard-installed Perl 5.10.0.

###With a user that’s always logged in
This is the easiest way to go, if you’re either uncomfortable with Unix
terminals and so forth, or are perfectly happy leaving your machine logged in
24/7. I have no experience of how this works with things like Mac OS X’s fast
user switching.

1. Save the `status.pl` and `download.pl` scripts somewhere in your home
   directory. I use `~/bin` (or, in common terms, a directory called `bin`
   directly in my home directory) because I’m a nerd.
2. Open `Terminal.app` (in `/Applications/Utilities/`) and type `crontab` and
   hit return.

You’re now editing your `crontab` (cron table) file in
[`vi`](http://en.wikipedia.org/wiki/Vi). This file allows you to specify how
often to execute specific commands ([see Wikipedia for more info on
cron](http://en.wikipedia.org/wiki/Cron)). The format is:

    mins hours day-of-month month day-of-week command

So if, like me, you’ve put `status.pl` in `~/bin` and want it to run every 5
minutes, saving its output to `~/logs/network_status.csv` (that file should
exist), you might add a line like:

    */5 * * * * ~/bin/status.pl >> ~/logs/network_status.csv

3. To add that line, enter `A` (note the capital) and paste that line (or your
   own variant) into the Terminal window. Make sure that the line is
   terminated with a newline character.
4. To save, press escape and type `:wq` and hit return.

<!-- Repeat steps 2-4 for `download.pl`, making sure to write to a different logfile. -->

###Without a logged-in user

TODO

Output
------

###`status.pl`
Each line of output offers the following fields, comma-separated and in the
following order:

    start-time of logging
    end-time of logging
    
    Connection state (Up, down, etc.)
    Connection protocol (PPPoA, etc.)
    Authentication mode
    Connection time
    External IP address
    
    Downstream speed
    Upstream speed
    
    Downstream attenuation
    Upstream attenuation
    Downstream noise (in dB)
    Upstream noise (in dB)

###`download.pl`

TODO