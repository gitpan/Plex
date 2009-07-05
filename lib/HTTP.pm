package Plex::HTTP;

use IO::Socket;
use HTTP::Status;
use Plex::HTTP::Call;
use HTTP::Request;
use HTTP::Date;
use URI::Escape;
use Plex::Text;

local $/ = undef;

@ISA = ( Plex::HTTP::Cache, Plex::HTTP::Call );

my $CRLF = "\015\012";

my %cfg = (
    'version'       =>      '1.1',
    'server'        =>      'plex/2.7',
);

sub new ($%) {
    my ($class, %args) = @_;
    $args{Listen}       ||= 10;
    $args{Proto}        ||= 'tcp';
    $args{Reuse}        ||= 1;
    $args{LocalPort}    ||= 80;
    my $s = IO::Socket::INET->new(%args)
        or die "Couldn't set up socket: $!";
    my $self = {};
    $self->{server} = $s;
    bless($self, $class);
    return $self;
}

sub accept ($) {
    my $self = shift;
    my $c = $self->{server}->accept();
    $self->{client} = $c;
    return $self;
}

sub get_request ($) {
    my $self = shift;
    my %data;
    my $c = $self->{client};
	my $req;
    while (<$c>) {
		$req = $req.$_;
		if ($_ eq $CRLF) { last; }
	}
	my $http = HTTP::Request->parse($req);
	$self->{req} = $http;
	return $self;
}

sub make ($$$$) {
    my ($self, $status, $type, $content) = @_;
    my $c = $self->{client};
    print $c "HTTP/$cfg{version} $status ".status_message($status).$CRLF;
    print $c "Date: ".time2str(localtime()).$CRLF;
    print $c "Server: $cfg{server}".$CRLF;
    print $c "Content-Type: $type".$CRLF;
    print $c "Content-Length: ".length($content).$CRLF.$CRLF;
    print $c $content;
}

sub make_error {
    my ($self, $status, $message) = @_;
    my $c = $self->{client};
    my $content = "$status ".status_message($status)."<br><b>$message</b><hr>".$cfg{server}.$CRLF;
    print $c "HTTP/$cfg{version} $status ".status_message($status).$CRLF;
    print $c "Date: ".time2str(localtime()).$CRLF;
    print $c "Server: $cfg{server}".$CRLF;
    print $c "Content-Type: text/html".$CRLF;
    print $c "Content-Length: ".length($content).$CRLF.$CRLF;
    print $c $content;
}

1;
