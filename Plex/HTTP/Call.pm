package Plex::HTTP::Call;

use File::MMagic;
use Plex::Compiler::Simple;

my $mm = new File::MMagic;
my %obj;

sub new {
    my ($class, $root) = @_;
    my $self = {};
    $self->{root} = $root;
    bless($self, $class);
    return $self;
}

sub handle {
    my ($self, $host, $file, $http) = @_;
    my $absolute = $Plex::ROOT."/".$host."/".$file;
    if ($file =~ /\/~(.*?)\/(.*)/) {
        $absolute = "/home/$1/$2";
    }
    
    $absolute =~ s/\/\//\//g;
    if (-d $absolute) {
        if(is_index_in_dir($absolute)) {
            my $path = $absolute."index.view";
            print "Called index file of $absolute\n";
            $http->make(200, "text/html", &Plex::View::exec($path));
        } else {
            $http->make_error(404, "No index file. LOL. You thought i'll give YOU directory listing!? :D");
        }
    } elsif (-e $absolute) {
        my $type = $mm->checktype_filename( $absolute );
        print "Type: $type :: $file\n";
        $type =~ /(.*?)\/(.*)/;
        if ($file =~ /\./) {
            if ($file =~ /\/(.*?)\.view$/i) {
                print "Call $absolute\n";
                $http->make(200, "text/html", &Plex::View::exec($absolute) );
            } elsif ($file =~ /\/(.*?)\.css/i) {
                local $/ = undef;
                open(CSS, "<$absolute");
                my $css = <CSS>;
                close(CSS);
                $http->make(200, "text/css", $css);
            } elsif ($file =~ /\/(.*?)\.gif/) {
                local $/ = undef;
                open(GIF, "<$absolute");
                my $gif = <GIF>;
                close(GIF);
                $http->make(200, "image/gif", $gif);
            } elsif ($file =~ /\.jpg/) {
                local $/ = undef;
                open(JPG, "<$absolute");
                my $jpg = <JPG>;
                close(JPG);
                $http->make(200, "image/jpg", $jpg);
            }
        } elsif ($file =~ /\/(.*?)$/) {
            print "Call $absolute\n";
            $http->make(200, "text/html", &Plex::View::exec($absolute) );
        } else {
            local $/ = undef;
            print "Delivering $file as $type\n";
            open(FILE, "<$absolute");
            my $file = <FILE>;
            close(FILE);
            $http->make(200, $type, $file);
        }
    } else {
        if (-e $absolute.".view") {
            print "Call $absolute".".view";
            $http->make(200, "text/html", &Plex::View::exec($absolute.".view"));
        } else {
            $http->make_error(404, "No such file or directory.");
        }
    }
}

sub is_index_in_dir {
	my $dir = shift;
	opendir(DIR, $dir);
	my @files = readdir(DIR);
	closedir(DIR);
	foreach my $file (@files) {
		if ($file eq "index.view") {
			return 1;
		} 
	}
	return 0;
}

1;
