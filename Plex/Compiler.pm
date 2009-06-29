package Plex::Compiler;

use Plex::Compiler::Lexer;

my $debug = 1;

@ISA = ( Plex::Compiler::Lexer );
my @comp;

sub new {
    my ($class, @tokens) = @_;
    my $self = {};
    @{$self->{tokens}} = @tokens;
    bless ($self, $class);
    return $self;
}

sub compile {
    my $self = shift;
    foreach my $token_ref (@{$self->{tokens}}) {
        my $to   = $token_ref->[1];
        $to =~ s/\?/$token_ref->[0]/;
        push(@comp, qq[$to\n]);
    }
    my $comp = join('', @comp);
    $self->{comp} = $comp;
    #$cache->cache_code( $comp );
    @comp = ();
    $comp = undef;
    return $self;
}

sub execute {
    my ($self, %ARGS) = @_;
    if (defined %ARGS) {
    local %ENV;
    foreach my $arg (keys %ARGS) {
        $ENV{$arg} = $ARGS{$arg};
    }
    }
    my $code = $self->{comp};
    eval($code) or die "error: $!";
    my @buffer = getbuf();
    my $buffer = join('', @buffer);
    $self->{buffer} = $buffer;
    return $self;
}

1;
