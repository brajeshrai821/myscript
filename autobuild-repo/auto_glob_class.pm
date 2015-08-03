#!/usr/bin/perl
# File:       auto_glob_class.pm
# Descr:      Global settings class.
# History:    2011-11-08 Anders Risberg       Initial version.
#
package auto_glob_class;
use strict;
use warnings;
use constant {false => 0, true => 1};
our $VERSION="1.00";

sub new {
  my($class)=@_;
  my $self=bless({},$class);
}

sub add {
  my($self,%args)=@_;
  my($key,$val)=%args;
  if($key) {
    if(exists $self->{$key}) {
      die "Key $key already exists.\n";
    }
    $self->{$key}=$val;
  }
  return $self->{target};
}
1;