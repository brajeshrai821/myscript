#!/usr/bin/perl
# File:       auto_funct_class.pm
# Descr:      Functions class.
# History:    2011-11-08 Anders Risberg       Initial version.
#
package auto_funct_class;
use strict;
use warnings;
use Fcntl;
use constant {false => 0, true => 1};
use constant {PROGRESS_INIT => -1, PROGRESS_AUTO => -2};
use auto_common qw(printex);
our $VERSION="1.00";

# Structure to keep functions to run.
use Class::Struct;
struct( func => [
        name => '$',
        descr => '$',
        params => '@',
]);

sub new {
  my($class)=@_;
  my $self=bless({},$class);
  $self->{funcs}=[];
  return $self;
}

# Descr: Adds a function to the function list.
# Params: <function reference> <description>
sub add {
  my ($self,$name,$descr,@params)=@_;
  my $func=func->new;
  $func->name($name);
  $func->descr($descr);
  my $i=0;
  foreach my $p (@params) {
    $func->params($i++,$p);
  }
  push(@{$self->{funcs}}, $func);
  return;
}

# Descr: Run the configurated functions from the function list.
# Parameters: 
sub run {
  my ($self)=@_;
  my $num_steps=scalar @{$self->{funcs}};
  if($num_steps > 0) {
    $self->progress(PROGRESS_INIT,"",++$num_steps);
    foreach my $f (@{$self->{funcs}}) {
      $self->progress(PROGRESS_AUTO,$f->descr,0);
      printex($f->descr."\n");
      &{$f->name}(@{$f->params});
    }
  }
  else {
    $self->progress(PROGRESS_INIT,"",1);
    $self->progress(PROGRESS_AUTO,"Done",0);
  }
  return;
}

# Descr: Write functions from the function list to workflow-file or screen.
# Params: <file name>
sub print {
  my ($self,$filename)=@_;
  if(defined $filename){sysopen OUT, $filename, O_RDWR|O_CREAT|O_APPEND|O_TRUNC or die "Couldn't open $filename.";} else {print "Number of functions: ".scalar @{$self->{funcs}}."\n";}
  foreach my $f (@{$self->{funcs}}) {
    my $str="";
    if(defined $filename){$str="$str".$f->name.",";} else {$str=$str.$f->name."(";}
    if(defined $filename){$str="$str".$f->descr.",";}
    my $i=@{$f->params};
    foreach my $p (@{$f->params}) {
      if(!ref($p)) {
        chomp($p);
        $str="$str$p";
        $str="$str," unless(--$i <= 0);
      }
      elsif(ref($p) eq "ARRAY") {
        my $i1=@{$p};
        foreach my $p1 (@{$p}) {
          chomp($p1);
          $str="$str$p1";
          $str="$str," unless(--$i1 <= 0);
        }
      }
      else {
        die "Error: Wrong type of reference.";
      }
    }
    if(defined $filename){print(OUT "$str\n");} else {print("Run function: $str);\n");};
  }
  close(OUT) unless ! defined $filename;
  return;
}

# Descr: Set and print progress information.
# Params: <PROGRESS_INIT|PROGRESS_AUTO> <text>
my $progress_num_steps=0;
my $progress_step=0;
sub progress {
  my ($self,$progress_type,$text,$num_steps)=@_;
  if($progress_type eq PROGRESS_INIT) {
    # Reset for auto progress
    $progress_num_steps=$num_steps;
    $progress_step=0;
    print "<#prog>0<#>$text<#>\n";
  }
  elsif($progress_type eq PROGRESS_AUTO && $progress_num_steps > 0) {
    # Auto progress
    $progress_step++;
    my $progress=(100 / ($progress_num_steps)) * $progress_step;
    $progress=sprintf("%d", $progress); # Convert to integer
    if($progress > 100) { $progress = 100; }
    if($progress < 0) { $progress = 0; }
    print "<#prog>$progress<#>$text<#>\n";
  }
  return;
}
1;