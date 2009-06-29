package Plex::Text;

sub html_escape ($) {
    my $string = shift;
    $string =~ s/</&lt;/g;
    $string =~ s/>/&gt;/g;
    $string =~ s/&/&amp;/g;
    $string =~ s/"/&quot;/g;
    return $string;
}

1;
