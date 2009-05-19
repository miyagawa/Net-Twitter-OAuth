package Net::Twitter::OAuth;

use strict;
use 5.008_001;
our $VERSION = '0.04';

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

sub oauth {
    my $self = shift;
    $self->{oauth};
}

# shortcuts defined in early releases
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

  # Do some Authentication work. See EXAMPLES

  my $tweets = $client->friends_timeline;
  my $res    = $client->update({ status => "I CAN HAZ OAUTH!" });

=head1 DESCRIPTION

Net::Twitter::OAuth is a Net::Twitter subclass that uses OAuth
authentication instead of the default Basic Authentication.

Note that this client only works with APIs that are compatible to OAuth authentication.

=head1 EXAMPLES

Here's how to authorize users as a desktop app mode:

  use Net::Twitter::OAuth;

  my $client = Net::Twitter::OAuth->new(
      consumer_key    => "YOUR-CONSUMER-KEY",
      consumer_secret => "YOUR-CONSUMER-SECRET",
  );

  # You'll save these token and secret in cookie, config file or session database
  my($access_token, $access_token_secret) = restore_tokens();
  if ($access_token && $access_token_secret) {
      $client->oauth->access_token($access_token);
      $client->oauth->access_token_secret($access_token_secret);
  }

  unless ($client->oauth->authorized) {
      # The client is not yet authorized: Do it now
      print "Authorize this app at ", $client->oauth->get_authorization_url, " and hit RET\n";

      <STDIN>; # wait for input

      my($access_token, $access_token_secret) = $client->oauth->request_access_token;
      save_tokens($access_token, $access_token_secret); # if necessary
  }

  # Everything's ready

In a web application mode, you need to save the oauth_token and
oauth_token_secret somewhere when you redirect the user to the OAuth
authorization URL.

  sub twitter_authorize : Local {
      my($self, $c) = @_;

      my $client = Net::Twitter::OAuth->new(%param);
      my $url = $client->oauth->get_authorization_url;

      $c->response->cookies->{oauth} = {
          value => {
              token => $client->oauth->request_token,
              token_secret => $client->oauth->request_token_secret,
          },
      };

      $c->response->redirect($url);
  }

And when the user returns back, you'll reset those request token and
secret to upgrade the request token to access token.

  sub twitter_auth_callback : Local {
      my($self, $c) = @_;

      my $cookie = $c->response->cookies->{oauth}->value;

      my $client = Net::Twitter::OAuth->new(%param);
      $client->oauth->request_token($client->{token});
      $client->oauth->request_token_secret($client->{token_secret});

      my($access_token, $access_token_secret)
          = $client->oauth->request_access_token;

      # Save $access_token and $access_token_secret in the database associated with $c->user
  }

Later on, you can retrieve and reset those access token and secret
before calling any Twitter API methods.

  sub make_tweet : Local {
      my($self, $c) = @_;

      my($access_token, $access_token_secret) = ...;

      my $client = Net::Twitter::OAuth->new(%param);
      $client->oauth->access_token($access_token);
      $client->oauth->access_token_secret($access_token_secret);

      # Now you can call any Net::Twitter API methods on $client
      my $status = $c->req->param('status');
      my $res = $client->update({ status => $status });
  }

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

=item oauth

  $client->oauth;

Returns Net::OAuth::Simple object to deal with getting and setting
OAuth tokens. See L<Net::OAuth::Simple> for details.

=back

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Net::Twitter>, L<Net::OAuth::Simple>

=cut
