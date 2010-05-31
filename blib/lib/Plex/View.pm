package Plex::View;

use File::MMagic::XS;
use Path::Abstract;

use Plex::Lexer;
use Plex::Compiler;

my $root = "/var/www";

my @out = ();

my $mm = new File::MMagic;

listDir($root);

sub listDir {
	my ($path,$d) = @_;
	my $filename;
	opendir(DIRHANDLE,$path) or die("Fehler: $path - $!\n") ;
	foreach my  $filename (readdir(DIRHANDLE)) { 
		next if ($filename =~ /^\.\.?$/);
		if ( -d "$path/$filename") {
			$d++ ;
			listDir("$path/$filename",$d);
		} else {
            my $absolute = $path."/".$filename;
			$absolute =~ s/$root//;
            my $res = $mm->checktype_filename("$path/$filename");
		    my $ext = path( "$path/$filename" )->extension;
            if($ext eq "" || $ext eq "px"){
                open(FILE, "<".$path."/".$filename);
                my $file = join('', <FILE>);
                close(FILE);
                Plex::Lexer::p( $file );
                Plex::Compiler::p(Plex::Lexer::_tokens());
                my $obj = Plex::Compiler::_obj();
                my $filters = Plex::Lexer::_filters();
                ::$cache{$absolute} = {
                    mime    =>  $res,
                    dyna    =>  $obj,
                    meth    =>  $Plex::Lexer::input_method,
                    filt    =>  $filters,
                };
            } else {
                open(FILE, "<".$path."/".$filename);
                my $file = join('', <FILE>);
                close(FILE);
                ::$cache{$absolute} = {
                    mime    =>  $res,
                    cont    =>  $file,
                };
            }
        }
	}
	closedir DIRHANDLE;
}

sub out {
    $_ = shift;
    push(@out, $_);
}

sub _out {
    return join('', @out);
}

1;
