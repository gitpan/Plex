package Plex::Types;

use MooseX::Types
    -declare => [qw(
        PositiveInt NegativeInt
    )];

use MooseX::Types::Moose qw/Int Str/;

subtype PositiveInt,
    as Int,
    where { $_ > 0 };

subtype NegativeInt,
    as Int,
    where { $_ < 0 };

1;
