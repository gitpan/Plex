package Plex::HTTP::Cache;

my %cache;

sub new {
    my $class = shift;
    return $class;
}

sub cache_code {
    my ($self, $file, $code) = @_;
    $cache{$file}{Code} = $code;
    return 1;
}

sub cache_out {
    my ($self, $file, $out) = @_;
    $cache{$file}{Out} = $out;
    return 1;
}

1;
