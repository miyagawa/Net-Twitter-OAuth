package Net::Twitter::OAuth;

use strict;
use 5.008_001;
our $VERSION = '0.02';

use base qw( Net::Twitter );

use Net::OAuth::Simple;
use Net::Twitter::OAuth::UserAgent;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();
    $self->{oauth} = Net::OAuth::Simple->new(
        tokens => {@_},
        urls => {
            request_token_url => "http://twitter.com/oauth/request_token",
            authorization_url => "http://twitter.com/oauth/authorize",
            access_token_url => "http://twitter.com/oauth/access_token",
        },
    );

    # override UserAgent
    $self->{ua} = Net::Twitter::OAuth::UserAgent->new($self->{oauth});

    $self;
}

sub oauth_token {
    my($self, @tokens) = @_;
    $self->{oauth}->access_token($tokens[0]);
    $self->{oauth}->access_token_secret($tokens[1]);
    return @tokens;
}

sub is_authorized {
    my $self = shift;
    $self->{oauth}->authorized;
}

sub oauth_authorize_url {
    my $self = shift;
    $self->{oauth}->get_authorization_url(@_);
}

sub request_access_token {
    my $self = shift;
    $self->{oauth}->request_access_token;
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Net::Twitter::OAuth - Net::Twitter subclass that uses OAuth instead of Basic Auth

=head1 SYNOPSIS

  use Net::Twitter::OAuth;

  my $client = Net::Twitter::OAuth->new(
      consumer_key    => "YOUR-CONSUMER-KEY",
      consumer_secret => "YOUR-CONSUMER-SECRET",
  );

  # You'll save these token and secret in cookie, config file or session database
  my($access_token, $access_token_secret) = restore_tokens();
  if ($access_token && $access_token_secret) {
      $client->oauth_token($access_token, $access_token_secret);
  }

  unless ($client->is_authorized) {
      # The client is not yet authorized: Do it now
      print "Authorize this app at ", $client->oauth_authorize_url, " and hit RET\n";

      <STDIN>; # wait for input

      my($access_token, $access_token_secret) = $client->request_access_token;
      save_tokens($access_token, $access_token_secret); # if necessary
  }

  # Everything's ready: same as Net::Twitter
  my $tweets = $client->friends_timeline;
  my $res    = $client->update({ status => "I CAN HAZ OAUTH!" });

=head1 DESCRIPTION

Net::Twitter::OAuth is a Net::Twitter subclass that uses OAuth
authentication instead of the default Basic Authentication.

Note that this client only works with APIs that are compatible to OAuth authentication.

=head1 METHODS

=over 4

=item new

  $client = Net::Twitter::OAuth->new(
      consumer_key => $consumer_key,
      consumer_secret => $consumer_secret,
  );

Creates a new Net::Twitter::OAuth object. Takes the parameters
C<consumer_key> and C<consumer_secret> that can be acquired at Twitter
Developer screen L<http://twitter.com/oauth_clients>.

=item oauth_token

  $client->oauth_token($access_token, $access_token_secret);

Sets access token and secret, saved in your app's local storage
(e.g. config file, cookie or session database). This allows you to
calling APIs once the application is authorized by the user.

=item is_authorized

  $client->is_authorized;

Returns the state if the app is already authorized to access APIs. If
this returns false, you should call I<oauth_authorize_url> etc. to let
user authorize the application.

=item oauth_authorize_url

  my $url = $client->oauth_authorize_url;

Returns the URL where the end user is asked to authorize the application.

=item request_access_token

  my($access_token, $access_token_secret) = $client->request_access_token;

Once the application is authorized by the user, your code should call
this method to exchange the generic token to access token for later
API calls. You probably want to save these token in a local storage so
that you can skip the authorization phase for the next run.

=back

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Net::Twitter>, L<Net::OAuth::Simple>

=cut
