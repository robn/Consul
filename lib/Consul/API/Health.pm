package Consul::API::Health;

use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str);

requires qw(version_prefix api_exec);

has _health_endpoint => ( is => 'lazy', isa => Str );
sub _build__health_endpoint {
    shift->version_prefix . '/health';
}

sub health {
    my ($self) = @_;
    return bless \$self, "Consul::API::Health::Impl";
}

package Consul::API::Health::Impl;

use Moo;

use JSON::MaybeXS qw(decode_json);
use Carp qw(croak);

sub node {
    my ($self, $node, %args) = @_;
    croak 'usage: $health->node($node, [%args])' if grep { !defined } ($node);
    map { Consul::API::Health::Check->new(%$_) } @{decode_json($$self->api_exec($$self->_health_endpoint."/node/".$node, 'GET', %args)->{content})};
}

sub checks {
    my ($self, $service, %args) = @_;
    croak 'usage: $health->checks($service, [%args])' if grep { !defined } ($service);
    map { Consul::API::Health::Check->new(%$_) } @{decode_json($$self->api_exec($$self->_health_endpoint."/checks/".$service, 'GET', %args)->{content})};
}

sub service {
    # service
    croak "not yet implemented";
}

sub state {
    my ($self, $state, %args) = @_;
    croak 'usage: $health->state($state, [%args])' if grep { !defined } ($state);
    map { Consul::API::Health::Check->new(%$_) } @{decode_json($$self->api_exec($$self->_health_endpoint."/state/".$state, 'GET', %args)->{content})};
}

package Consul::API::Health::Check;

use Moo;
use Types::Standard qw(Str);

has node         => ( is => 'ro', isa => Str, init_arg => 'Node',        required => 1 );
has id           => ( is => 'ro', isa => Str, init_arg => 'CheckID',     required => 1 );
has name         => ( is => 'ro', isa => Str, init_arg => 'Name',        required => 1 );
has status       => ( is => 'ro', isa => Str, init_arg => 'Status',      required => 1 );
has notes        => ( is => 'ro', isa => Str, init_arg => 'Notes',       required => 1 );
has output       => ( is => 'ro', isa => Str, init_arg => 'Output',      required => 1 );
has service_id   => ( is => 'ro', isa => Str, init_arg => 'ServiceID',   required => 1 );
has service_name => ( is => 'ro', isa => Str, init_arg => 'ServiceName', required => 1 );

1;
