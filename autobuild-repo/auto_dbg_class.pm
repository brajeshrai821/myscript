#!/usr/bin/perl
# File:       auto_dbg_class.pm
# Descr:      Debug class.
# History:    2011-11-08 Anders Risberg       Initial version.
#
package auto_dbg_class;
use strict;
use warnings;
use Fcntl;
use constant {false => 0, true => 1};
our $VERSION="1.00";

sub new {
  my($class)=@_;
  my $self=bless({},$class);

  $self->{_FirstTime}=true;

  # Process values - initial
  $self->{_WorkingSetSize}=0;
  $self->{_PeakWorkingSetSize}=0;
  $self->{_MaximumWorkingSetSize}=0;
  $self->{_MinimumWorkingSetSize}=0;
  $self->{_PageFaults}=0;
  $self->{_VirtualSize}=0;
  $self->{_PeakVirtualSize}=0;
  # Process values - last
  $self->{WorkingSetSize}=0;
  $self->{PeakWorkingSetSize}=0;
  $self->{MaximumWorkingSetSize}=0;
  $self->{MinimumWorkingSetSize}=0;
  $self->{PageFaults}=0;
  $self->{VirtualSize}=0;
  $self->{PeakVirtualSize}=0;
  return $self;
}

# Descr: Prints current memory usage for this process.
use Win32::OLE qw/in/;
sub memory_usage {
  my ($self,$capt)=@_;
  if(! $auto_common::common_glob->{debug_mode}) { return; }
  $capt = "" unless defined $capt;
  
  my $objWMI=Win32::OLE->GetObject('winmgmts:\\\\.\\root\\cimv2');
  my $processes=$objWMI->ExecQuery("select * from Win32_Process where ProcessId=$$");
  foreach my $proc (in $processes) {
    print "Memory usage for $proc->{ProcessId} ($proc->{Name}), $capt:\n";
    print "  Working set size:      ", $proc->{WorkingSetSize}/1000,   " (", ($proc->{WorkingSetSize} -        $self->{WorkingSetSize})/1000,  ")", " (", ($proc->{WorkingSetSize} -        $self->{_WorkingSetSize})/1000,  ") KB\n";
    print "  Peak Working set size: ", $proc->{PeakWorkingSetSize},    " (",  $proc->{PeakWorkingSetSize} -    $self->{PeakWorkingSetSize},    ")", " (",  $proc->{PeakWorkingSetSize} -    $self->{_PeakWorkingSetSize},    ") KB\n";
    print "  Max Working set size:  ", $proc->{MaximumWorkingSetSize}, " (",  $proc->{MaximumWorkingSetSize} - $self->{MaximumWorkingSetSize}, ")", " (",  $proc->{MaximumWorkingSetSize} - $self->{_MaximumWorkingSetSize}, ") KB\n";
    print "  Min Working set size:  ", $proc->{MinimumWorkingSetSize}, " (",  $proc->{MinimumWorkingSetSize} - $self->{MinimumWorkingSetSize}, ")", " (",  $proc->{MinimumWorkingSetSize} - $self->{_MinimumWorkingSetSize}, ") KB\n";
    print "  Page faults:           ", $proc->{PageFaults},            " (",  $proc->{PageFaults} -            $self->{PageFaults},            ")", " (",  $proc->{PageFaults} -            $self->{_PageFaults},            ")\n";
    print "  Virtual size:          ", $proc->{VirtualSize},           " (", ($proc->{VirtualSize} -           $self->{VirtualSize})/1000,     ")", " (", ($proc->{VirtualSize} -           $self->{_VirtualSize})/1000,     ") KB\n";
    print "  Peak Virtual size:     ", $proc->{PeakVirtualSize}/1000,  " (", ($proc->{PeakVirtualSize} -       $self->{PeakVirtualSize})/1000, ")", " (", ($proc->{PeakVirtualSize} -       $self->{_PeakVirtualSize})/1000, ") KB\n";
    print "---------------------------------------------\n";
    
    # Store til next time
    $self->{WorkingSetSize}        = $proc->{WorkingSetSize};
    $self->{PeakWorkingSetSize}    = $proc->{PeakWorkingSetSize};
    $self->{MaximumWorkingSetSize} = $proc->{MaximumWorkingSetSize};
    $self->{MinimumWorkingSetSize} = $proc->{MinimumWorkingSetSize};
    $self->{PageFaults}            = $proc->{PageFaults};
    $self->{VirtualSize}           = $proc->{VirtualSize};
    $self->{PeakVirtualSize}       = $proc->{PeakVirtualSize};
    if($self->{_FirstTime}) {
      # Store initial values
      $self->{_FirstTime}=false;
      $self->{_WorkingSetSize}        = $proc->{WorkingSetSize};
      $self->{_PeakWorkingSetSize}    = $proc->{PeakWorkingSetSize};
      $self->{_MaximumWorkingSetSize} = $proc->{MaximumWorkingSetSize};
      $self->{_MinimumWorkingSetSize} = $proc->{MinimumWorkingSetSize};
      $self->{_PageFaults}            = $proc->{PageFaults};
      $self->{_VirtualSize}           = $proc->{VirtualSize};
      $self->{_PeakVirtualSize}       = $proc->{PeakVirtualSize};
    }
    last;
  }
  return;
}

# Descr: Prints array.
sub prarr {
  my ($space,@arr)=@_;
  $space=$space."  ";
  my $cnt=1;
  foreach my $a (@arr) {
    if(ref $a eq "ARRAY") {
      prarr($space,@{$a});
      #print join("\n",@{$a}),"\n";
    }
    else {
      $a='' unless defined $a;
      printf "%s*%02d: %s\n", $space, $cnt++, $a;
    }
  }
  return;
}

# Descr: Go back two steps and get the caller
sub whowasi {(caller(2))[3]}

# Descr: Prints debug info.
sub debug {
  my ($self,@params)=@_;
  if(! $auto_common::common_glob->{debug_mode}) {
    return false; # Make sure the script continues after calling this method during no-debug.
  }
  printf "--%s()\n", $self->whowasi();
  $self->prarr("",@params);
  return $auto_common::common_glob->{debug_ret};
}
1;