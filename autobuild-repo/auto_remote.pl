#!/usr/bin/perl
# File:       auto_remote.pl
# Descr:      Conversation with a remote host.
# Parameters: <command>
# Returns:    Error code from command.
# History:    2011-11-22 Anders Risberg       Initial version.
#
use strict;
use warnings;
use English qw(-no_match_vars); # Avoids regex performance penalty
use constant {false => 0, true => 1};

die "ARGV" unless (@ARGV!=0);
my (@cmd)=@ARGV;
my $ret=system(@cmd);
exit ($ret>>8);
