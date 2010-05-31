package Plex::Compiler;

use Switch;
use Moose;
use Plex::View;
use Plex::Exception;
use MooseX::Types::Moose qw/Int Str/;

no strict;      #   Needed vor $&

use CSS::Minifier::XS;
use JavaScript::Minifier::XS;

my $obj = ();

sub p {
    my @tokens = shift;
    foreach my $token (@tokens){
        switch($token->[0]){
            case "PERL" {
                push(@{$obj}, $token->[2]);
            }
            case "INIT" {
                push(@{$obj}, $token->[2]);
            }
            case "SUB" {
                push(@{$obj}, $token->[2]);
            }
            case "MINIFY" {

                switch($token->[1]){
                    case "JS" {
                        my$js=JavaScript::Minifier::XS::minify($token->[2]);
                        push(@{$obj}, "out(".$js.");");
                    }
                    case "CSS" {
                        my $css = CSS::Minifier::XS::minify($token->[2]);
                        push(@{$obj}, "out(".$css.");");
                    }
                }
            }
            case "PRINT" {
                push(@{$obj}, "out(".$token->[2].");");
            }
        }
    }
}



sub e {
    my ($obj, $input, $request_method, $query_string, @filters) = @_;
    my $flag = 0;
    my %in = cq_array($query_string);
    if($input eq $request_method){
        foreach my $filter (@filters){
            my $type = $filter->[1];
            if(!$type){next;}
            my $func = "is_$type";
            if(!(&$func($in{$filter->[0]}))){
                $flag = 1;
                out("<b>".$filter->[2]."</b><br>");
            }
        }
    } else {
        $flag = 1;
        out("<b>wrong method</b>");
    }
    if(!$flag){
        print join('', $obj);
        eval(join('', $obj)) or die($!);
        return join('', Plex::View::_out());
    } else {
        return join('', Plex::View::_out());
    }
}

1;

sub cq_array {
    my $query = shift;
    my %in = ();
    if (length($query) > 0){
        my $buffer = $query;
        my @pairs = split(/&/, $buffer);
        foreach my $pair (@pairs){
            my ($name, $value) = split(/=/, $pair);
            $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
            $in{$name} =  $value;
        }
    }
    return %in;
}

sub _obj {
    return $obj;
}
