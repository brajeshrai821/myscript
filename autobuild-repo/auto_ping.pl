#!/usr/bin/perl
# File:       auto_ping.pl
# Descr:      Ping a remote host.
#             The Perl module Net leaks memory and is thus put in a separate script.
# Parameters: <remote host>
# Returns:    True if host is alive.
# History:    2011-11-14 Anders Risberg       Initial version.
#
use strict;
use warnings;
use English qw(-no_match_vars); # Avoids regex performance penalty
use Net::Ping;
use constant {false => 0, true => 1};

die "ARGV" unless (@ARGV!=0);
my ($remote_host)=@ARGV;

my $ret=false;
my $p=Net::Ping->new();
if($p->ping($remote_host)) { $ret=true; }
$p->close();

exit ($ret);
