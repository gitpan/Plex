package Plex::View;

use Plex::Compiler;

our %cache;
our @need;
our $need_as_string;
my @buffer;

sub exec {
    my $file = shift;
    eval($cache{$file}) or die $!;
    my $buffer = join('', @buffer);
    @buffer = ();
    return $buffer;
}

sub out {
    my $string = shift;
    push(@buffer, $string);
    return 1;
}

sub show_cached {
    foreach (keys %cache) {
        print "$_   =>  [$cache{$_}]\n";
    }
}

sub compile_all {
    my $root = $Plex::ROOT;
    traversedir($root);
    if ($Plex::USER_DIR) {
        traversedir("/home/");
    }
    foreach my $need (@need) {
        my $lexer = Plex::Compiler::Lexer->new();
        $lexer->read_file( $need );
        $lexer->lex;
        my $compiler = Plex::Compiler->new( @{$lexer->{tokens}} );
        $compiler->compile;
        print "after compiling it is ".$compiler->{comp};
        my $code = $compiler->{comp};
        $cache{$need} = $code;
        $code = undef;
        $compiler->{comp} = undef;
        $lexer = undef;
        $compiler = undef;
        print "after deleting it is ".$compiler->{comp};
    }
    $need_as_string = join('', @need);
}

sub traversedir {
  my $path = shift;
  opendir(my $dhl,"$path") || die "Can't open directory: $!";
  my @files = grep {!/^\.{1,2}$/ } readdir($dhl);
  foreach my $file (@files) {
    if(-d "$path$file") {
      traversedir("$path$file");
    } else {
      my $absolute = "$path/$file";
      if ($absolute =~ /\./) {
         if ($absolute =~ /\.view/i) {
            push(@need, $absolute);
         }
      } else {
           push(@need, $absolute);
      }
    }
  }
  closedir($dhl);
}

1;
