#!/usr/bin/perl
# File:       auto_dbi.pl
# Descr:      Get a value from the database.
#             The Perl module DBI leaks memory and is thus put in a separate script.
# Parameters: <remote host>
# Returns:    Retrieved value on STDOUT.
# History:    2011-11-14 Anders Risberg       Initial version.
#
use strict;
use warnings;
use English qw(-no_match_vars); # Avoids regex performance penalty
use DBI;
use constant {false => 0, true => 1};

die "ARGV" unless (@ARGV!=0);
my ($orauser,$orapwd,$orasid,$cmd)=@ARGV;

my $ret="";
my $db = DBI->connect("dbi:Oracle:$orasid",$orauser,$orapwd,{PrintError => 0,RaiseError => 1});
my $sth = $db->prepare($cmd);
$sth->execute();
my @row=$sth->fetchrow_array;
$sth->finish();
$db->disconnect() if defined($db);
if ((scalar @row) > 0) { $ret=$row[0]; }

print $ret;
exit 0;
