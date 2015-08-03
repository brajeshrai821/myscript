#!/usr/bin/perl
# File:       auto_common.pm
# Descr:      Autobuild common routines.
# History:    2010-03-22 Anders Risberg       Initial version.
#             2010-06-05 Anders Risberg       Release 1.2.19.
#             2010-06-16 Anders Risberg       Fixed parameter handling in progress.
#             2010-06-22 Anders Risberg       Added delay().
#             2010-11-26 Anders Risberg       Check if startup_mdb.pl exist before trying to run it.
#                                             Added symbols to indicate the status for e-boot.
#             2011-06-17 Anders Risberg       Added serialization/de-serialization functions.
#
package auto_common;
use strict;
use warnings;
use English qw(-no_match_vars); # Avoids regex performance penalty
use POSIX qw(strftime);
use Fcntl;
use IO::File;
use Time::HiRes qw (sleep);
use constant {false => 0, true => 1};

BEGIN {
  use Exporter();
  our (@ISA, @EXPORT_OK);
  @ISA = qw(Exporter);
  @EXPORT_OK = qw(printex remote_cmd remote_cmd_piped remote_cmd_outp remote_cmd_outp_inject remote_cp sys_cmd sys_cmd_outp);
}
our @EXPORT_OK;

# Non-exported package globals
use auto_glob_class;
our $common_glob;

use auto_dbg_class;
our $debug_info;

BEGIN {
  # Initialize common globals
  $common_glob=auto_glob_class->new;
  $common_glob->add(debug_mode => false); # True = run with debug
  $common_glob->add(debug_ret => false);  # Return valus from debug
  $common_glob->add(silent_mode => false);
  $common_glob->add(this_app => "");
  $common_glob->add(print_formatted => false);
  $common_glob->add(print_color_code => "!@!cf9");
  $common_glob->add(print_indent => 0);
  $common_glob->add(script_version => "");
  $common_glob->add(config_version => "");
  
  # Initialize debug info
  $debug_info=auto_dbg_class->new;
}

# Descr: Extended print.
# Params: <string> <log-file only>
sub printex {
  my ($str,$not_on_scr)=@_;
  my $format="";
  my $indent="";
  my $print_indent = (defined $common_glob->{print_indent}) ? $common_glob->{print_indent} : 0;
  my $print_formatted = (defined $common_glob->{print_formatted}) ? $common_glob->{print_formatted} : false;
  my $print_color_code = (defined $common_glob->{print_color_code}) ? $common_glob->{print_color_code} : "";
  my $this_app = (defined $common_glob->{this_app}) ? $common_glob->{this_app} : "";
  for (my $i=0; $i < $print_indent; $i++) { $indent=$indent."  "; }
  if($print_formatted) {$format=$print_color_code." ";}
  unless(defined($not_on_scr) && $not_on_scr == 1) {print($format,"[",$this_app,"]> ",$indent,$str);}
  if(LOG->opened()) {print(LOG (strftime "%H:%M:%S", localtime)," [",$this_app,"]> ",$indent,$str);}
  return;
}

# Descr: Get script-version.
# Params: <source-dir path>
sub get_version {
  my ($sd)=@_;
  my $ver="";
  my $filename="$sd/../docs/ver.txt";
  if(-e $filename) {
    open my $input_fh, "<", $filename or die "Couldn't open the version file '$filename' - $!";
    while(<$input_fh>) { $ver = $_; chomp($ver); }
    close $input_fh;
  }
  return $ver;
}

# Descr: Check version number format.
# Params: <version number as x.y.z>
sub check_version_format {
  my ($version)=@_;
  if($version=~ m{^([0-9]+)            # First number
                   (?:\.[0-9]+){2}     # 2 x . number
                $}x) {                 # End
    if($1 =~ m{^0[0-9]}) { return 0; } # Err: first number starts with 0
    else { return 1; } 
  }
  else { return 0; }
}

# Descr: Initiates the log-file.
# Params: <log-file path>
sub init_log {
  my ($filename)=@_;
  sysopen LOG, $filename, O_RDWR|O_CREAT|O_APPEND;
  return;
}

# Descr: Deinitiates the log-file.
# Params: 
sub deinit_log {
  close LOG;
  return;
}

# Descr: Parse the command line for input parameters.
# Params: <command line arguments> 
# Returns: Reference to an array of input parameters.
sub parse_commandline {
  my(@argv)=@_;
  my %input=();
  foreach my $arg (@argv) {
    (my $var, my $val)=split(/=/,$arg);
    $input{$var}=$val;
  }
  return \%input;
}

# Descr: Read configuration files.
# Params: <file name> <configuration> <configuration group> <append to each repeating variable> <do not fail on missing group>
sub rconf {
  my ($filename,$config,$group,$append,$continue_nomatch)=@_;
  my $match=0;
  open my $input_fh, "<", $filename or die "Couldn't open the configuration file '$filename' - $!";
  while(<$input_fh>) {
    chomp; # No newline
    s/#.*//; # No comments
    s/^\s+//; # No leading white
    s/\s+$//; # No trailing white
    next unless length; # Go on if anything left
    #print "$_\n";
    if($match == 0) {
      # Check for opening tag
      if(substr($_,length($_)-1,1) eq "{") {
        chop; # Strip "{"
        s/\s+$//; # No trailing white
        if($_ eq $group){ $match=1; next; }
      }
    }
    elsif(substr($_,0,1) eq "}" && $match == 1) { # Closing tag
      last;
    }
    else { # Got a config line
      my ($name, $value)=split(/\s*=\s*/, $_, 2); # Split each line into name value pairs
      #print "$name, $value\n";
      $value=~s/^\"+//; # No leading "'s
      $value=~s/\"+$//; # No trailing "'s
      $value=~s/(\$(\w+))/$config->{$2}/g;
      # Create a hash of the name value pairs
      if($append) {
        $config->{$name}="" unless defined $config->{$name};
        $config->{$name}=$config->{$name}.$value;
      }
      else {
        $config->{$name}=$value;
      }
    }
  }
  close $input_fh ;
  if($match == 0) {
    if(!$continue_nomatch) {
      die "Couldn't find group $group in config-file $filename";
    }
    else {
      return 1;
    }
  }
  return 0;
}

# Descr: Show configuration parameters.
# Params: <configuration>
sub sconf {
  my ($config)=@_;
  foreach my $config_key (keys %{$config}) {
    print("$config_key = $config->{$config_key}\n");
  }
  return;
}

# Descr: Remove file.
# Params: <path to file> <text>
sub remove_file {
  my ($path,$text)=@_;
  if($text ne "") {
    printex("$text\n");
  }
  if($path ne "") {
    unlink "$path";
  }
  return;
}

# Descr: Remove directory treee.
# Params: <path do directory>
sub remove_dir {
  my ($dir)=@_;
  if(! -d "$dir") { return; }
	local *DIR;
	opendir DIR, $dir or die "Coludn't find/open directory $dir ($!)";
	for(readdir DIR) {
	  next if /^\.{1,2}$/;
	  my $path = "$dir/$_";
		unlink $path if -f $path;
		remove_dir($path) if -d $path;
	}
	closedir DIR;
	rmdir $dir or print "Couldn't remove directory $dir ($!)\n";
  return;
}

# Descr: Reboots a host and waits for it to start up.
# Params: <ssh-command to reach host> <host name> <number of retries> <time between retries> <ticker symbol to show>
# Returns: Time to reboot if ok; otherwise 0.
sub reboot_host {
  my ($ssh_cmd,$remote_host,$retries,$time,$symbol)=@_;
  $symbol="p" unless defined $symbol;

  # Create a temporary flag-file that will delete itself after reboot
  my $boot_file="autobuild_reboot";
  my $boot_path="/etc/init.d/$boot_file";
  my $text="#!/bin/bash\n# This file was created by the Autobuild-system. It can safely be removed.\nrm -f /etc/rc.d/rc5.d/S99$boot_file\nrm -f $boot_path\n";
  remote_cmd(true, $ssh_cmd, $remote_host, "\"rm -f /etc/rc.d/rc5.d/S99$boot_file;rm -f $boot_path;echo '$text' >$boot_path;chmod +x $boot_path;ln -s $boot_path /etc/rc.d/rc5.d/S99$boot_file;\"");

  # Get current "last reboot-time"
  my ($ret, $boot_time)=remote_cmd_outp(true, false, $ssh_cmd, $remote_host, "who -b");
  
  # Reboot
  remote_cmd(true, $ssh_cmd, $remote_host, "shutdown -t 5 -r now");

  # Wait for the system to come back
  # Output:
  #  -: system doesn't answer to ping.
  #  p: system answers to ping.
  #  P: system answers to ping for the first time since a while.
  #  +: system has been rebooted (last boot time changed). Now wait for flag-file to be removed.
  my $count=$retries;
  my $ping_cnt=0;
  my $noping=0;
  my $wait_text="";
  print "<#stay>1<#>\n";
  while(1) {
    $wait_text=$wait_text.$symbol;
    print "$wait_text\n";
    my $pinged_ok=ping($remote_host);
    if($pinged_ok) {
      $symbol="p";
      if($noping eq 1 && ++$ping_cnt > 2) { # Only query if we had a connection loss and a few sucessful pings
        $symbol="P";
        # Make sure that "last reboot-time" has changed
        my ($ret, $bt)=remote_cmd_outp(false, false, $ssh_cmd, $remote_host, "who -b");
        if($ret eq 0 && $boot_time ne $bt) {
          $symbol="+";
          # Check if flag-file was removed
          my ($ret, $flag_file)=remote_cmd_outp(false, false, $ssh_cmd, $remote_host, "[[ -e $boot_path ]] && echo 1 || echo 0");
          if($ret eq 0 && $flag_file==0) {
            last; # Re-boot was completed
          }
        }
      }
    }
    else {
      $noping=1;
      $ping_cnt=0;
      $symbol="-";
    }
    $count--;
    if($count > 0) { delay($time,true); }
    else { last; }
  }
  print "<#stay>0<#>\n";

  # Success depends on counter
  my $ttc=($time*($retries-$count));
  if($count > 0 && $ttc > 0) { return $ttc; }
  else { return 0; }
}

# Descr: Ping a remote host.
# Params: <host to ping>
# Returns: True if host is alive,
sub ping {
  my($remote_host)=@_;
  my $ret=sys_cmd(false, "\"".$auto_settings::settings_glob->{perl}."\"", "\"".$auto_settings::settings_glob->{srcdir}."/auto_ping.pl\"", $remote_host);
  return $ret;
}

# Descr: Runs a remote command.
# Params: <die on error> <command> <remote host> <remote command>
# Returns: Error code (unshifted).
sub remote_cmd {
  my ($die_on_error,$cmd,$remote_host,$remote_cmd)=@_;
  my $ret=sys_cmd($die_on_error, "\"".$auto_settings::settings_glob->{perl}."\"", "\"".$auto_settings::settings_glob->{srcdir}."/auto_remote.pl\"", @$cmd, $remote_host, $remote_cmd);
  return $ret;
}

# Descr: Runs a remote command and pipe the output to a file.
# Params: <die on error> <command> <remote host> <remote command> <file to pipe to>
# Returns: Error code (unshifted).
sub remote_cmd_piped {
  my ($die_on_error,$cmd,$remote_host,$remote_cmd,$pipe_file)=@_;
  my $ret=sys_cmd_piped($die_on_error, $pipe_file, "\"".$auto_settings::settings_glob->{perl}."\"", "\"".$auto_settings::settings_glob->{srcdir}."/auto_remote.pl\"", @$cmd, $remote_host, $remote_cmd);
  return $ret;
}

# Descr: Runs a remote command and takes care of the output.
# Params: <die on error> <capture stderr> <command> <remote host> <remote command>
# Returns: Output from command.
sub remote_cmd_outp {
  my ($die_on_error,$capture_stderr,$cmd,$remote_host,$remote_cmd)=@_;
  my ($ret, $outp)=sys_cmd_outp($die_on_error, $capture_stderr, "\"".$auto_settings::settings_glob->{perl}."\"", "\"".$auto_settings::settings_glob->{srcdir}."/auto_remote.pl\"", @$cmd, $remote_host, $remote_cmd);
  return ($ret, $outp);
}

# Descr: Runs a remote command with injected command in front, and takes care of the output.
# Params: <die on error> <capture stderr> <command> <remote host> <remote command> <injection>
# Returns: Output from command.
sub remote_cmd_outp_inject {
  my ($die_on_error,$capture_stderr,$cmd,$remote_host,$remote_cmd,$inject)=@_;
  my ($ret, $outp)=sys_cmd_outp($die_on_error, $capture_stderr, $inject, "\"".$auto_settings::settings_glob->{perl}."\"", "\"".$auto_settings::settings_glob->{srcdir}."/auto_remote.pl\"", @$cmd, $remote_host, $remote_cmd);
  return ($ret, $outp);
}

# Descr: Runs a remote copy.
# Params: <die on error> <command> <source path> <target path>
# Returns: Error code (unshifted).
sub remote_cp {
  my ($die_on_error,$cmd,$src_path,$trg_path)=@_;
  my $ret=sys_cmd($die_on_error, "\"".$auto_settings::settings_glob->{perl}."\"", "\"".$auto_settings::settings_glob->{srcdir}."/auto_remote.pl\"", @$cmd, $src_path, $trg_path);
  return $ret;
}

# Descr: Runs a system command.
# Params: <die on error> <command>
# Returns: Error code (unshifted).
sub sys_cmd {
  my ($die_on_error,@cmd)=@_;
  my $ret=system(@cmd);
  if($die_on_error) {
    $ret>>8==0 or die {msg => "Command @cmd failed ($!).", ret => $ret>>8};
  }
  return $ret;
}

# Descr: Runs a system command and pipes the output to a file.
# Params: <die on error> <command> <file to pipe to>
# Returns: Error code (unshifted).
sub sys_cmd_piped {
  my ($die_on_error,$pipe_file,@cmd)=@_;
  my $ret=system("@cmd > $pipe_file");
  if($die_on_error) {
    $ret>>8==0 or die {msg => "Command @cmd failed ($!).", ret => $ret>>8};
  }
  return $ret;
}

# Descr: Runs a system command and takes care of the output.
# Params: <die on error> <capture stderr> <command>
# Returns: Output from command.
sub sys_cmd_outp {
  my ($die_on_error,$capture_stderr,@cmd)=@_;
  my $outp="";
  if ($capture_stderr) { $outp=`@cmd 2>&1`; }
  else { $outp=`@cmd`; }
  my $ret=$?;
  if($die_on_error) {
    $ret>>8==0 or die {msg => "Command @cmd failed ($!). Output was: $outp", ret => $ret>>8};
  }
  return ($ret, $outp);
}

# Descr: Analyze log-file with latest version.
# Params: <log-file directory> <path to original> <prefix of files to search> <path to filter directory> <filter name> <lines to avoid in analyze> <diff command> <extra normalizing entries>
sub analyze_latest {
  my ($dir,$orig_path,$filePrefix,$filter_dir,$filter_name,$avoid_lines,$diff,@norm_extra)=@_;

  if(! -d "$dir") {
    printex("  Couldn't find log-files directory $dir\n");
    return;
  }
  if(! -e "$filter_dir/filter") {
    printex("  Couldn't find filter file $filter_dir/filter\n");
    return;
  }
  if(! -e "$orig_path") {
    return;
  }
  
  # Get latest file to analyze
  my $latest_file = get_latest_file($dir, "^".$filePrefix);
  if($latest_file eq "") {
    printex("  No latest file to analyze\n");
    return;
  }
  printex("  Latest file to analyze is $latest_file\n");
  
  # Normalize dates and times
  my $fileFltr1 = "filter_res_1";
  my $fileFltr2 = "filter_res_2";
  normalize("$dir/$latest_file", $fileFltr1, @norm_extra);
  normalize("$orig_path", $fileFltr2, @norm_extra);

  # Load and filter newest file
  my $ret1 = filter($fileFltr1, $fileFltr1."1", "$filter_dir/filter", $filter_name, $avoid_lines);
  # Load and filter original file
  my $ret2 = filter($fileFltr2, $fileFltr2."1", "$filter_dir/filter", $filter_name, $avoid_lines);
  
  # Use filtered files if filtering succeeded; otherwise use the normalized files.
  # Filtering will "fail" if no filtering name was found in the filter-file or if no output files were written.
  if($ret1 == 1 || $ret2 == 1) {
    $fileFltr1 = $fileFltr1."1";
    $fileFltr2 = $fileFltr2."1";
  }
  
  # Run diff on normalized/filtered files
  unless(-d "$dir/diff") { mkdir("$dir/diff", 755) or die "Couldn't create directory $dir/diff."; }
  sys_cmd(true, "\"$diff\" $fileFltr1 $fileFltr2 > \"$dir/diff/".$filePrefix."_diff.log\"");
  
  # Remove temporary files
  unlink("filter_res_1");
  unlink("filter_res_2");
  unlink("filter_res_11");
  unlink("filter_res_21");
  return;
}

# Descr: Get the latest file in a collection of files with similar names.
# Params: <path> <regular expression to describe files to look for>
sub get_latest_file {
  my ($dir,$file_expr)=@_;
  opendir(DIR, "$dir");
  my @files = grep {/$file_expr/} readdir(DIR);
  closedir(DIR);

  my %newest;
  $newest{mtime} = 0;
  $newest{file} = 0;
  foreach my $filename (@files) {
    my $mtime=(stat("$dir/$filename"))[9];
    $newest{file} = $filename and $newest{mtime} = $mtime if $newest{mtime} < $mtime;
  }
  
  if($newest{file} ne 0) { return $newest{file}; }
  else { return ""; }
}

# Descr: Filter a file against a filter collection.
# Params: <source file path> <output file path> <filter file name> <filter name> <extra lines lines to filter>
sub filter {
  my ($srce,$trgt,$filter_file,$filter_name,$avoid_lines)=@_;
  if($avoid_lines ne "") { $avoid_lines = "|$avoid_lines"; }

  # Load filter
  my %config=();
  $config{"filter"} = "";
  my $ret=rconf($filter_file, \%config, $filter_name, true, true);
  if($ret == 1) { return 0; } # No written files
  #sconf(\%config);

  open my $input_fh, "<", $srce or die "Couldn't open the file '$srce' - $!";
  sysopen my $output_fh, $trgt, O_RDWR|O_CREAT|O_APPEND|O_TRUNC;
  my $wrote_file = 0; # No written files yet
  while(<$input_fh>) { 
    chomp;
    if(! /$config{"filter"}$avoid_lines/) {
      print($output_fh "$_\n");
      $wrote_file = 1;
    }
  }
  close $input_fh;
  close $output_fh;
  return $wrote_file;
}

# Descr: Normalize file by replacing common patterns with standard text, e.g. 10:05:34 -> hh:mm:ss
# Params: <source file path> <output file path> <extra normalizing commands>
sub normalize {
  my ($srce,$trgt,@others)=@_;
  open my $input_fh, "<", $srce or die "Couldn't open the file '$srce' - $!";
  sysopen my $output_fh, $trgt, O_RDWR|O_CREAT|O_APPEND|O_TRUNC;
  while(<$input_fh>) {
    chomp;
    $_=~s/(?i)(Mon|Tue|Wed|Thu|Fri|Sat|Sun) +(?i)(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) +[0-9]{1,2} +[0-9]{2}:[0-9]{2}:[0-9]{2} +[a-zA-Z]{3,4} +[0-9]{4}/ddd mmm dd hh:mm:ss xxxx yyyy/g;
    $_=~s/(?i)(Mon|Tue|Wed|Thu|Fri|Sat|Sun) +(?i)(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) +[0-9]{1,2} +[0-9]{2}:[0-9]{2}:[0-9]{2} +[0-9]{4}/ddd mmm dd hh:mm:ss yyyy/g;
    $_=~s/(?i)(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) +[0-9]{1,2} +[0-9]{2}:[0-9]{2}/mmm dd hh:mm/g;
    $_=~s/[0-9]{1,2}-(?i)(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-[0-9]{2}/dd-mmm-yy/g;
    $_=~s/[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}(:|\.)[0-9]{2}(:|\.)[0-9]{2}/yyyy-mm-dd hh:mm:ss/g;
    $_=~s/[0-9]{4}-[0-9]{2}-[0-9]{2}/yyyy-mm-dd/g;
    $_=~s/[0-9]{2}:[0-9]{2}:[0-9]{2}/hh:mm:ss/g;
    $_=~s/[0-9]{8}T[0-9]{6}/yyyymmddThhmmss/g;
    foreach my $o (@others) {
      $_=~$o;
    }
    print($output_fh "$_\n");
  }
  close $input_fh;
  close $output_fh;
  return;
}

# Descr: Delays execution for given number of seconds.
# Params: <delay in seconds>
sub delay {
  my ($delay,$_silent)=@_;
  my $silent=defined($_silent) ? $_silent : false;
  if($delay > 0) {
    printex("Wait for $delay seconds ...\n") unless $silent;
    sleep $delay;
  }
  return;
}

sub whoami {(caller(1))[3]}  # Go back one step
sub whoami_file {(caller(1))[1]}
sub whoami_line {(caller(1))[2]}
sub whowasi {(caller(2))[3]} # Go back two steps
sub whowasi_file {(caller(2))[1]}
sub whowasi_line {(caller(2))[2]}

# Descr: Signal handler initialization.
# Parameters: <optional function name to signal handler>
sub sighandler_init {
  my ($sighandler_func)=@_;
  if (!defined($sighandler_func) || $sighandler_func==0) {$sighandler_func=\&sighandler;}
  $SIG{'INT'} = $sighandler_func;
  $SIG{'QUIT'} = $sighandler_func;
  $SIG{'__DIE__'} = $sighandler_func;
  $SIG{'__WARN__'} = $sighandler_func;
  #$SIG{'INT'} = 'DEFAULT'; # restore default action
  #$SIG{'QUIT'} = 'IGNORE'; # ignore SIGQUIT
  return;
}

# Descr: Signal handler.
# Parameters: <signal text|signal hash (msg, ret)>
sub sighandler {
  my ($sig)=@_;
  my $whoa=whoami();
  my $whoa_file=whoami_file();
  my $whoa_line=whoami_line();
  my $who=whowasi();
  my $who_file=whowasi_file();
  my $who_line=whowasi_line();
  my $ret=1;
  my $msg="";
  
  if($common_glob->{print_formatted}) {print "<#stay>0<#>\n";} # Reset any stay-mode
  if(ref($sig) eq "HASH") {
    $ret=$sig->{ret};
    $msg=$sig->{msg};
  }
  else {$msg=$sig;}

  printex("Error: $msg\n");
  if(defined($who) && $who ne "") { printex("  Called from: $who_file, line $who_line, function $who()\n"); }
  else { printex("  Called from: $whoa_file, line $whoa_line\n"); }
  printex("  Error code:  $ret\n");
  
  deinit_log();

  if($ret==0){$ret=255;} # Default error code to make parent exit
  exit($ret);
}
1;