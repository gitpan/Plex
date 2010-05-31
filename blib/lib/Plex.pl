use strict;
use IO::Socket;
use Symbol;
use POSIX;
use HTTP::HeaderParser::XS;
use URI;

my $CRLF = "\015\012";

my $server = IO::Socket::INET->new( LocalPort => 80,
                                    Type      => SOCK_STREAM,
                                    Proto     => 'tcp',
                                    Reuse     => 1,
                                    Listen    => 10 )
  or die "making socket: $@\n";

my $PREFORK                = 12;
my $MAX_CLIENTS_PER_CHILD  = 12;
my %children               = ();
my $children               = 0;

$SIG{CHLD} = \&REAPER;
$SIG{INT}  = \&HUNTSMAN;

for (1 .. $PREFORK) {
    make_new_child();
}

while (1) {
    sleep;
    for (my $i = $children; $i < $PREFORK; $i++) {
        make_new_child();
    }
}

sub REAPER {
    $SIG{CHLD} = \&REAPER;
    my $pid = wait;
    $children --;
    delete $children{$pid};
}

sub HUNTSMAN {
    local($SIG{CHLD}) = 'IGNORE';
    kill 'INT' => keys %children;
    exit;
}
   
sub make_new_child {
    my $pid;
    my $sigset;
    
    # block signal for fork
    $sigset = POSIX::SigSet->new(SIGINT);
    sigprocmask(SIG_BLOCK, $sigset)
        or die "Can't block SIGINT for fork: $!\n";
    
    die "fork: $!" unless defined ($pid = fork);
    
    if ($pid) {
        sigprocmask(SIG_UNBLOCK, $sigset)
            or die "Can't unblock SIGINT for fork: $!\n";
        $children{$pid} = 1;
        $children++;
        return;
    } else {
        $SIG{INT} = 'DEFAULT';
    
        sigprocmask(SIG_UNBLOCK, $sigset)
            or die "Can't unblock SIGINT for fork: $!\n";
    
        for (my $i=0; $i < $MAX_CLIENTS_PER_CHILD; $i++) {
	        my $client = $server->accept()     or last; 
            my $req;
            my ($method, $host, $uri, $query);
            while(<$client>){$req.= $_;last if$_=~/^$CRLF$/;}
            my $hdr = HTTP::HeaderParser::XS->new( \"$req") or _k($client);
            if($hdr->getMethod == M_GET){
                $method = "GET";
                # slows down, better solution?
                my $u = URI->new($hdr->getURI());
                $query = $u->query;
                if($cache{$hdr->getURI()}{dyna}){
                    my $out = Plex::Compiler::e($cache{$hdr->getURI()}{dyna}, $cache{$hdr->getURI()}{meth}, $method, $query, @{$cache{$hdr->getURI()}{filt}});
                    print $client "$out\n";
                }
            } elsif ($hdr->getMethod == M_POST){
                $method = "POST";
            } else {
                _k($client);
            }
            $uri = $hdr->getURI();
            $client->close();
            undef($client);
	    }
        exit;
    }
}

sub _k {
    my $client = shift;
    print $client "Go away.$CRLF";
    $client->close();
    last;
}
