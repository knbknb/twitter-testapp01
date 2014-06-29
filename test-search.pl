#
# command-line client to
# search for a real-name user on twitter.
# will return some metadata and the latest tweet in YAML format
# or a more compact format
#
# SQL command , output piped into this script
# sqsh <credentials> -C "set rowcount 2 select DISTINCT first_name + ' ' + middle_names + ' ' + last_name as names from person where last_name like 'St%' order by last_name asc" -h -J iso_1 -b | grep -vr '^\s*$' |  uniq | xargs -i perl test-search.pl --user="{}"

use Modern::Perl;
use Net::Twitter;
use Scalar::Util 'blessed';
use JSON::XS;
use YAML::XS;
use Getopt::Long;
use Try::Tiny;
use autodie;

my %opts = ();
GetOptions( \%opts, 'user=s' , 'skip_existing');
$opts{user} ||= "Knut Behrends";
$opts{skip_existing} ||= 0;

# When no authentication is required:
#my $nt = Net::Twitter->new(legacy => 0);

# As of 13-Aug-2010, Twitter requires OAuth for authenticated requests:
my $consumer_key    = "PHzdOCT7ykEQxSnfRLU0g";
my $consumer_secret = `grep cs= ~/.twitconfig | cut -c 4-`;
my $token           = "51690654-120SFwNLis2v7Agzw1NV0G1cBpRNnJacxkqY4OKMc";
my $token_secret    = `grep ts= ~/.twitconfig | cut -c 4-`;
chomp $consumer_secret;
chomp $token_secret;


my $nt = Net::Twitter->new(
	traits              => [qw/API::RESTv1_1/],
#	traits              => [qw/OAuth API::Search API::REST/],
	consumer_key        => $consumer_key,
	consumer_secret     => $consumer_secret,
	access_token        => $token,
	access_token_secret => $token_secret,
         ssl => 1
);

my $search_term = $opts{user};
$search_term =~ s/\s+$//;
$search_term =~ s/^\s+//;
try {
	my $r = $nt->users_search($search_term);
        my $search_term_lc = lc $search_term;
        $search_term_lc =~  s/\W+/_/g;
	#
	#print Dump $r  ;
    my $dir = "twusers"; 
    mkdir $dir unless -d $dir;
    my $coder = JSON::XS->new->utf8->pretty->allow_nonref;
	for my $user (@$r) {
		
		my $t = $user->{status}{retweeted_status}{text} ||= "";
		say "search_term: $search_term";
		say "$user->{description}:" if $user->{description};
		say "tweets: $user->{statuses_count}, friends: $user->{friends_count}";
		say "$user->{name} <$user->{screen_name}> since $user->{created_at}, id: $user->{id}";
		say "$user->{name} : '$t'";
		# only consider users that tweet and have friends (they are following someone)
		next if ($user->{statuses_count} == 0 && $user->{friends_count} == 0);
		my $n = $user->{name};
		$n =~ s/\s+/_/g;
                if (-d "$dir/$search_term_lc" &&  $opts{skip_existing}){
                     say "skipping dir  '$search_term_lc'";
                     say "";
                    next; 
                } elsif (! -d  "$dir/$search_term_lc"){
        	        mkdir "$dir/$search_term_lc" ;
                }
		my $outfilename = "./$dir/$search_term_lc/twitterusers.$n--" . $user->{screen_name} . ".json";
		open my $outfile, ">", $outfilename;
		for my $user (@$r) {			 
 
			print $outfile  $coder->encode ($r);
			
		}
		close $outfile;

		$t = "";
		sleep 1;
	}

}
catch {
	my $err = $_;
	warn Dump $_ unless blessed $err && $err->isa('Net::Twitter::Error');

	warn Dump "HTTP Response Code: ", $err->code, "\n", "HTTP Message......: ", $err->message, "\n", "Twitter error.....: ", $err->error, "\n";
}

=pod
- contributors_enabled: !!perl/scalar:JSON::XS::Boolean 0
  created_at: Sun Jun 28 09:20:54 +0000 2009
  default_profile: !!perl/scalar:JSON::XS::Boolean 0
  default_profile_image: !!perl/scalar:JSON::XS::Boolean 0
  description: sudo -f su. Ask me anything.
  favourites_count: 0
  follow_request_sent: !!perl/scalar:JSON::XS::Boolean 0
  followers_count: 5
  following: !!perl/scalar:JSON::XS::Boolean 0
  friends_count: 58
  geo_enabled: !!perl/scalar:JSON::XS::Boolean 0
  id: 51690654
  id_str: '51690654'
  is_translator: !!perl/scalar:JSON::XS::Boolean 0
  lang: en
  listed_count: 0
  location: Germany
  name: Knut Behrends
  notifications: !!perl/scalar:JSON::XS::Boolean 0
  profile_background_color: ffffff
  profile_background_image_url: http://a1.twimg.com/profile_background_images/294252305/temp_kuvva_production_84_779_1.jpeg
  profile_background_image_url_https: https://si0.twimg.com/profile_background_images/294252305/temp_kuvva_production_84_779_1.jpeg
  profile_background_tile: !!perl/scalar:JSON::XS::Boolean 0
  profile_image_url: http://a3.twimg.com/profile_images/286714859/hblau_normal.jpg
  profile_image_url_https: https://si0.twimg.com/profile_images/286714859/hblau_normal.jpg
  profile_link_color: '059997'
  profile_sidebar_border_color: ffffff
  profile_sidebar_fill_color: ffffff
  profile_text_color: 0f0304
  profile_use_background_image: !!perl/scalar:JSON::XS::Boolean 1
  protected: !!perl/scalar:JSON::XS::Boolean 0
  screen_name: sudo_f
  show_all_inline_media: !!perl/scalar:JSON::XS::Boolean 0
  status:
    contributors: ~
    coordinates: ~
    created_at: Fri Jul 08 07:33:16 +0000 2011
    favorited: !!perl/scalar:JSON::XS::Boolean 0
    geo: ~
    id: 89235586455584769
    id_str: '89235586455584769'
    in_reply_to_screen_name: ~
    in_reply_to_status_id: ~
    in_reply_to_status_id_str: ~
    in_reply_to_user_id: ~
    in_reply_to_user_id_str: ~
    place: ~
    retweet_count: 33
    retweeted: !!perl/scalar:JSON::XS::Boolean 0
    retweeted_status:
      contributors: ~
      coordinates: ~
      created_at: Thu Jul 07 21:21:02 +0000 2011
      favorited: !!perl/scalar:JSON::XS::Boolean 0
      geo: ~
      id: 89081513433497601
      id_str: '89081513433497601'
      in_reply_to_screen_name: ~
      in_reply_to_status_id: ~
      in_reply_to_status_id_str: ~
      in_reply_to_user_id: ~
      in_reply_to_user_id_str: ~
      place: ~
      retweet_count: 33
      retweeted: !!perl/scalar:JSON::XS::Boolean 0
      source: <a href="http://twitter.com/tweetbutton" rel="nofollow">Tweet Button</a>
      text: Interesting article "My Summer at an Indian Call Center" http://t.co/Bow206m
        via @motherjones
      truncated: !!perl/scalar:JSON::XS::Boolean 0
    source: <a href="http://twitter.com/download/android" rel="nofollow">Twitter for
      Android</a>
    text: 'RT @mrdenny: Interesting article "My Summer at an Indian Call Center" http://t.co/Bow206m
      via @motherjones'
    truncated: !!perl/scalar:JSON::XS::Boolean 0
  statuses_count: 29
  time_zone: Bern
  url: ~
  utc_offset: 3600
  verified: !!perl/scalar:JSON::XS::Boolean 0

=cut
