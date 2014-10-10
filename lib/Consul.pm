package Consul;

# ABSTRACT: Client library for consul

use namespace::sweep;

use HTTP::Tiny 0.014;
use URI::Escape qw(uri_escape);
use Carp qw(croak);

use Moo;
use Type::Utils qw(class_type);
use Types::Standard qw(Str Int Bool HashRef);

has host => ( is => 'ro', isa => Str, default => '127.0.0.1' );
has port => ( is => 'ro', isa => Int, default => 8500 );

has ssl => ( is => 'ro', isa => Bool, default => 0 );

has http => ( is => 'lazy', isa => class_type('HTTP::Tiny') );
sub _build_http { HTTP::Tiny->new };

has version_prefix => ( is => 'ro', isa => Str, default => '/v1' );

has _url_base => ( is => 'lazy' );
sub _build__url_base {
    my ($self) = @_;
    ($self->ssl ? 'https' : 'http') .'://'.$self->host.':'.$self->port;
}

sub _prep_url {
    my ($self, $path, %args) = @_;
    my $trailing = $path =~ m{/$};
    my $url = $self->_url_base.join('/', map { uri_escape($_) } split('/', $path));
    $url .= '/' if $trailing;
    $url .= '?'.$self->http->www_form_urlencode(\%args) if %args;
    $url;
}

sub api_exec {
    my ($self, $path, $method, %args) = @_;
    my $content = delete $args{_content};
    delete $args{$_} for grep { m/^_/ } keys %args;
    my $res = $self->http->request($method, $self->_prep_url($path, %args), defined $content ? { content => $content } : {});
    return $res if $res->{success};
    croak "$res->{status} $res->{reason}: $res->{content}";
}

with qw(
    Consul::API::ACL
    Consul::API::Agent
    Consul::API::Catalog
    Consul::API::Event
    Consul::API::Health
    Consul::API::KV
    Consul::API::Session
    Consul::API::Status
);

use Consul::Check;
use Consul::Service;

1;
