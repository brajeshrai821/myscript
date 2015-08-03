#!/usr/bin/perl
# File:       auto_run_cmd.pl
# Descr:      Run a command.
# Parameters: <command>
# History:    2011-05-26 Anders Risberg       Initial version.
#
use strict;
use warnings;
$|++; # Auto-flush
use English qw(-no_match_vars); # Avoids regex performance penalty
use constant {false => 0, true => 1};
use auto_sel;
use auto_sel_wrp;

# Check arguments and pop the command
die "ARGV" unless (@ARGV!=0);
my ($cmd)=@ARGV;
# Parse the command line
my $input=auto_common::parse_commandline(@ARGV);
# Initialize selector (must be silent to here)
$input=auto_sel::init($0,0,$input);

# Convert parameters to a hash list where empty keys (undefined initial value) has the value true
my %params=();
while(my($k, $v)=each(%$input)) {
  $v=true unless defined $v;
  # Remove initial dash on keys
  if($k ne "" && (substr $k, 0, 1) eq "-") {
    $k=substr $k, 1;
  }
  $params{$k}=$v;
}

# Run the command
auto_sel_wrp::run_cmds($cmd,\%params);

# De-initialize selector
auto_sel::deinit();

exit(0);