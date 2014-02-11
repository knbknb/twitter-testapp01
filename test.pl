#
# almost unaltered example code from
# http://search.cpan.org/dist/Net-Twitter/lib/Net/Twitter.pod
#

use Modern::Perl;
use Net::Twitter;
use Scalar::Util 'blessed';

# When no authentication is required:
#my $nt = Net::Twitter->new(legacy => 0);
my $consumer_key    = "PHzdOCT7ykEQxSnfRLU0g";
my $consumer_secret = `grep cs= ~/.twitconfig | cut -c 4-`;
my $token           = "51690654-120SFwNLis2v7Agzw1NV0G1cBpRNnJacxkqY4OKMc";
my $token_secret    = `grep ts= ~/.twitconfig | cut -c 4-`;
chomp $consumer_secret;
chomp $token_secret;

# As of 13-Aug-2010, Twitter requires OAuth for authenticated requests
my $nt = Net::Twitter->new(
	traits              => [qw/OAuth API::REST/],
	consumer_key        => $consumer_key,
	consumer_secret     => $consumer_secret,
	access_token        => $token,
	access_token_secret => $token_secret,
	ssl => 1 
);

#my $result = $nt->update('Hello, world! - created this tweet from boilerplate code of Net::Twitter perl module.');
#exit;
my $high_water = 10;
eval {
	my $statuses = $nt->friends_timeline( { since_id => $high_water, count => 100 } );
	for my $status (@$statuses) {
		print "$status->{created_at} <$status->{user}{screen_name}> $status->{text}\n";
	}
};
if ( my $err = $@ ) {
	die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

	warn "HTTP Response Code: ", $err->code, "\n", "HTTP Message......: ", $err->message, "\n", "Twitter error.....: ", $err->error, "\n";
}
