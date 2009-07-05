package Plex::Compiler::Lexer;

my %default = (
    STANDARD    =>  {
        START       =>      '<%',
        END         =>      '%>',
        TO          =>      '?',
    },
);

my %rules = (
    COMMENT     =>  {
        START       =>      '<\#',
        END         =>      '\#>',
        TO          =>      '# ?\n',
    },
);

my %interpolations = (
    PRINT   =>  {
        TAG       =>      '=',
        TO        =>      'out qq[?];',
    },
);

my $text;
my @tokens;

sub new {
    my $class = shift;
    my $self = {};
    bless ($self, $class);
    return $self;
}

sub read {
    my ($self, $text_r) = @_;
    $text = $text_r;
    return 1;
}

sub read_file {
    my ($self, $file) = @_;
    local $/ = undef;
    open(FILE, "<$file");
    $text = <FILE>;
    close(FILE);
    return 1;
}

sub lex {
    my $self = shift;
    while (1) {
        last if $text =~ m/\G\z/;
        if ($text =~ m/ \G $default{STANDARD}{START}(.+?)$default{STANDARD}{END} /sgcx) {
            push @tokens, [$1, $default{STANDARD}{TO}]; 
        }
        foreach my $type (keys %rules) {
            if ($text =~ m/ \G $rules{$type}{START}(.+?)$rules{$type}{END} /sgcx) {
                push @tokens, [$1, $rules{$type}{TO}];
            }
        }
        foreach my $interpolation (keys %interpolations) {
            if ($text =~ m/ \G $default{STANDARD}{START}$interpolations{$interpolation}{START}(.+?)$default{STANDARD}{END} /sgcx) {
            push @tokens, [$1, $interpolations{$interpolation}{TO}];
            }
        }
        match_text() or
        die "Syntax error!";
    }
    @{$self->{tokens}} = @tokens;
    @tokens = undef;
    return $self;
}

sub match_text {
    if ($text =~ m/ \G (.+?) (?= <\/?[%#] | \z) /sgcx) {
        push @tokens, [$1, 'out qq[?];'];
        return 1;
    }
    return 0;
}

1;
