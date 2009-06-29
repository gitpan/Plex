sub traversedir {
  my $path = shift;
  opendir(my $dhl,"$path") || die "Can't open directory: $!";
  my @files = grep {!/^\.{1,2}$/ } readdir($dhl);
  foreach my $file (@files) {
    if(-d "$path$file") {
      traversedir("$path$file");
    } else {
      print "$path/$file\n";
    }
  }
  closedir($dhl);
}

traversedir("/var/www/");
