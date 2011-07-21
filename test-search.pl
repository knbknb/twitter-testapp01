#
# search for a real-name user on twitter.
# will return some metadata and the latest tweet in YAML format
#
# almost unaltered example code from
# http://search.cpan.org/dist/Net-Twitter/lib/Net/Twitter.pod
# 
#

use Modern::Perl;
use Net::Twitter;
use Scalar::Util 'blessed';

# When no authentication is required:
#my $nt = Net::Twitter->new(legacy => 0);
my $consumer_key    = "PHzdOCT7ykEQxSnfRLU0g";
my $consumer_secret = `grep cs= ~/.twitconfig | cut -c 4-`;
my $token           = "51690654-m8eqF1EOVoyIwnDxYnLykgANEGpTfSTLvgzshhpOd";
my $token_secret    = `grep ts= ~/.twitconfig | cut -c 4-`;
chomp $consumer_secret;
chomp $token_secret;

# As of 13-Aug-2010, Twitter requires OAuth for authenticated requests
my $nt = Net::Twitter->new(
	traits              => [qw/OAuth API::Search API::REST/],
	consumer_key        => $consumer_key,
	consumer_secret     => $consumer_secret,
	access_token        => $token,
	access_token_secret => $token_secret,
);

#use JSON::XS;
my $search_term = "Knut Behrends";
my $r = $nt->users_search($search_term);
#print encode_json $r;
use YAML::XS;
print Dump $r;

    
if ( my $err = $@ ) {
	die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

	warn "HTTP Response Code: ", $err->code, "\n", "HTTP Message......: ", $err->message, "\n", "Twitter error.....: ", $err->error, "\n";
}
