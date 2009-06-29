package Plex::Compiler::Simple;

use Exporter;
use Plex::Compiler::Cache;
@ISA = ( Exporter );
use Plex::Compiler;
my $lexer = Plex::Compiler::Lexer->new();

@EXPORT = (compile_file);
@EXPORT_OK = (compile_file);

sub compile_file {
    my (undef, $file) = @_;
    $lexer->read_file( $file );
    $lexer->lex;
    my $compiler = Plex::Compiler->new( @{$lexer->{tokens}} );
    $compiler->compile;
    $compiler->execute;
    return $compiler->{buffer};
}

sub cache_compile {
	my (undef, $file) = @_;
	$lexer->read_file( $file );
	$lexer->lex;
	my $compilr = Plex::Compiler->new( @{$lexer->{tokens}} );
	$compiler->compile;
	$compiler->execute;
	$Plex::Compiler::Cache{$file} = sub { $compiler->{buffer} };
}

sub compile {
    my (undef, $str) = @_;
    $lexer->read( $str );
    $lexer->lex;
    my $compiler = Plex::Compiler->new( @{$lexer->{tokens}} );
    $compiler->compile;
    $compiler->execute;
    return $compiler->{buffer};
}

1;
