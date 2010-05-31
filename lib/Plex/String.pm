package Plex::String;

sub Password {
    my $length = $_[0];

    my $password;
    my $_rand;

    if (!$password_length) {
        $length = 12;
    }

    my @chars = split(" ",
        "a b c d e f g h i j k l m n o
        p q r s t u v w x y z - _ % # |
        0 1 2 3 4 5 6 7 8 9");

    srand;

    for (my $i=0; $i <= $length ;$i++) {
        $_rand = int(rand 41);
        $password .= $chars[$_rand];
    }
    return $password;
}

1;
