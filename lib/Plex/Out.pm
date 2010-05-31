package Plex::Out;

use Exporter;
@ISA = qw( Exporter );
@EXPORT = qw(&out);

my @out = ();

sub out {
    $_ = shift;
    push(@out, $_);
}

sub _out {
    return join('', @out);
}

1;
