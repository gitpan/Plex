package Plex::Exception;

sub n {
    my $error = shift;
    if($ENV{PLEX_DEV} == 1){
        Plex::View::out("Tha error is:".$error."\n");
    } else {
        Plex::View::out("xaaaAn error occured $error!");
    }
}

1;
