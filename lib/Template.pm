package Plex::Template;

local $/ = undef;

sub display {
    my $display = shift;
}

sub compile {
    my $file = shift;
    open(FILE, "<$file");
    my $text = <FILE>;
    close(FILE);  
}

1;
