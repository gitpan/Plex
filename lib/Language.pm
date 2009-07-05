package Plex::Language;

use Filter::Util::Call;

sub import {
	my ($type) = @_;
	my ($status);
	if (($status = filter_read() > 0)) {
		s/\/\*(.*?)\*\//MultiLineComment($1)/seg;
	} 
	$status;
}

sub MultiLineComment {
	my $comment = shift;
	while (<$comment>) {
		chomp;
	}
	return $comment;
}

1;