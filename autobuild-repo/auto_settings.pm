#!/usr/bin/perl
# File:       auto_settings.pm
# Descr:      Autobuild settings.
# History:    2011-02-02 Anders Risberg       Initial version (moved from auto_run_all.pl).
#
package auto_settings;
use strict;
use warnings;
use Cwd;

# Non-exported package globals
use auto_glob_class;
our $settings_glob;

BEGIN {
  my $srcdir=getcwd;$srcdir=~tr!\\!/!s;

  # Initialize common settings
  $settings_glob=auto_glob_class->new;
  $settings_glob->add(max_config_version => "1.5.0");
  $settings_glob->add(srcdir => $srcdir);
  $settings_glob->add(perl => $^X);
  
  $settings_glob->add(temp_path => "c:/autobuild_temp");
  $settings_glob->add(setenv => "cscript \"$srcdir/senv.vbs\" //NoLogo");

  $settings_glob->add(pack_file_script => "autobuild.tgz");
  $settings_glob->add(pack_file_runcons => "autobuild_runcons.tgz");
  $settings_glob->add(pack_file_offset => "autobuild_offset.tgz");
  $settings_glob->add(pack_file_pictures => "autobuild_pict.tgz");
  $settings_glob->add(pack_file_spide => "autobuild_spide.tgz");
  $settings_glob->add(file_ws500_license => "WS500License.ini");
  $settings_glob->add(file_ws500_licence => "WS500Licence.ini");

  $settings_glob->add(rsync_exclude => ["core*", "..."]);
  $settings_glob->add(non_scada_types => ["UDW", "DISTRIBUTED"]);
  
  if(-d "$srcdir/win") {
    # New style paths
    $settings_glob->add(linux_script_path => "$srcdir/linux");
    $settings_glob->add(win_script_path => "$srcdir/win");
    $settings_glob->add(win_bin_path => "$srcdir/win");
    $settings_glob->add(conf_path => "$srcdir/conf");
    $settings_glob->add(diff_path => "$srcdir/../projects/diff");
  }
  else {
    # Change to old style paths if necessary
    $settings_glob->add(linux_script_path => "$srcdir/../linux");
    $settings_glob->add(win_script_path => "$srcdir/bin");
    $settings_glob->add(win_bin_path => "$srcdir/bin");
    $settings_glob->add(conf_path => "$srcdir/../conf");
    $settings_glob->add(diff_path => "$srcdir/../projects/diff");
  }
  
  $settings_glob->add(tar => $settings_glob->{win_bin_path}."/bsdtar.exe");
  $settings_glob->add(ssh => $settings_glob->{win_bin_path}."/plink.exe");
  $settings_glob->add(scp => $settings_glob->{win_bin_path}."/pscp.exe");
  $settings_glob->add(cygpath => $settings_glob->{win_bin_path}."/cygpath.exe");
  $settings_glob->add(diff => $settings_glob->{win_bin_path}."/diff.exe");
  $settings_glob->add(auto_create_de400_path => $settings_glob->{win_script_path}."/auto_create_de400.pl");
  $settings_glob->add(logfiles_path => $settings_glob->{temp_path}."/logs");
  $settings_glob->add(hubfiles_path => $settings_glob->{temp_path}."/hub");
}
1;