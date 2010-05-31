package Plex::Lexer;

my $tokens = ();
my $filters = ();
our $input_method;

sub p {
    $_ = shift;
    while(1){
        last if m/\G\z/;
        match_perl() or
        match_init() or
        match_sub() or
        match_minify() or
        match_print() or
        match_filters() or
        match_text() or
        die("Syntax error!");
    }
}

sub match_perl {
    if(m/ \G <%perl>(.+?)<\/%perl> /sgcx){
        push(@{$tokens}, ["PERL", 0e0, $1]);
        return 1;
    }
    return 0;
}

sub match_init {
    if(m/ \G <%init>(.+?)<\/%init> /sgcx){
        push(@{$tokens}, ["INIT", 0e0, $1]);
        return 1;
    }
    return 0;
}

sub match_sub {
    if(m/ \G <%sub:(.+?)>(.+?)<\/%sub> /sgcx){
        push(@{$tokens}, ["SUB", $1, $2]);
        
        return 1;
    }
    return 0;
}

sub match_filters {
    if(m/ \G <%filters:(.+?)>(.+?)<\/%filters> /sgcx){
        $input_method = $1;
        my $s = $2;
        while($s =~ m/<%f:(.+?):(.+?)>(.+?)<\/%f>/sgcx){
            my $variable = $1;
            my $type = $2;
            my $message = $3;
            push(@{$filters}, [$1, $2, $3]);
        }
        return 1;
    }
    return 0;
}

sub match_minify {
    if(m/ \G <%minify:(.+?)>(.+?)<\/%minify> /sgcx){
        push(@{$tokens}, ["MINIFY", $1, $2]);
        return 1;
    }
    return 0;
}

sub match_print {
    if(m/ \G <%= (.+?) %> /sgcx){
        push(@{$tokens}, ["PRINT", 0e0, $1]);
        return 1;
    }
    return 0;
}

sub match_text {
    if(m/ \G (.+?) (?= <\/?[%] | \z) /sgcx){
        push(@{$tokens}, ["TEXT", 0e0, $1]);
        return 1;
    }
    return 0;
}

sub _tokens {
    return @{$tokens};
}

sub _filters {
    return $filters;
}

1;
