#!/usr/bin/perl
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Net::Twitter::OAuth;

my $client = Net::Twitter::OAuth->new(
    consumer_key => $ENV{TWITTER_CONSUMER_KEY},
    consumer_secret => $ENV{TWITTER_CONSUMER_SECRET},
);

unless ($client->oauth->authorized) {
    # The client is not yet authorized: Do it now
    print "Authorize this app at ", $client->oauth->get_authorization_url, " and hit RET\n";
    system "open", $client->oauth->get_authorization_url;

    <STDIN>; # wait for input
    $client->oauth->request_access_token;
}

binmode STDOUT, ":utf8";

my $tweets = $client->friends_timeline;
for my $tweet (@$tweets) {
    printf "%s: %s (%s)\n", $tweet->{user}{name}, $tweet->{text}, $tweet->{created_at};
}

print "\nSomething to say: ";
binmode STDIN, ":encoding(utf-8)";
chomp(my $tweet = <STDIN>);
my $res = $client->update({ status => $tweet });

print "Tweeted: http://twitter.com/$res->{user}{screen_name}/status/$res->{id}\n";


