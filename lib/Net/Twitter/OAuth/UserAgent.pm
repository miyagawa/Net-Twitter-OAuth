package Net::Twitter::OAuth::UserAgent;
use strict;
use warnings;

sub new {
    my($class, $oauth) = @_;
    bless { oauth => $oauth }, $class;
}

sub get {
    my $self = shift;
    my($url) = @_;
    $self->{oauth}->make_restricted_request($url, 'GET');
}

sub post {
    my $self = shift;
    my($url, $args) = @_;
    # Net::OAuth::Simple doesn't really do POST encoding but seems to work
    $self->{oauth}->make_restricted_request($url, 'POST', %$args);
}

1;
