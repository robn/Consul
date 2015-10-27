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

package
    Consul::API::Health::Impl; # hide from PAUSE

use Moo;

use JSON::MaybeXS;
use Carp qw(croak);

sub node {
    my ($self, $node, %args) = @_;
    croak 'usage: $health->node($node, [%args])' if grep { !defined } ($node);
    [ map { Consul::API::Health::Check->new(%$_) } @{decode_json($$self->api_exec($$self->_health_endpoint."/node/".$node, 'GET', %args)->{content})} ];
}

sub checks {
    my ($self, $service, %args) = @_;
    croak 'usage: $health->checks($service, [%args])' if grep { !defined } ($service);
    [ map { Consul::API::Health::Check->new(%$_) } @{decode_json($$self->api_exec($$self->_health_endpoint."/checks/".$service, 'GET', %args)->{content})} ];
}

sub service {
    my ($self, $service, %args) = @_;
    croak 'usage: $health->service($service, [%args])' if grep { !defined } ($service);
    [ map { Consul::API::Health::Service->new(%$_) } @{decode_json($$self->api_exec($$self->_health_endpoint."/service/".$service, 'GET', %args)->{content})} ];
}

sub state {
    my ($self, $state, %args) = @_;
    croak 'usage: $health->state($state, [%args])' if grep { !defined } ($state);
    [ map { Consul::API::Health::Check->new(%$_) } @{decode_json($$self->api_exec($$self->_health_endpoint."/state/".$state, 'GET', %args)->{content})} ];
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

package Consul::API::Health::Service;

use Moo;
use Types::Standard qw(ArrayRef);
use Type::Utils qw(class_type);

has node    => ( is => 'ro', isa => class_type('Consul::API::Catalog::ShortNode'),      init_arg => 'Node',    required => 1, coerce => sub { Consul::API::Catalog::ShortNode->new($_[0]) } );
has service => ( is => 'ro', isa => class_type('Consul::API::Agent::Service'),          init_arg => 'Service', required => 1, coerce => sub { Consul::API::Agent::Service->new($_[0]) } );
has checks  => ( is => 'ro', isa => ArrayRef[class_type('Consul::API::Health::Check')], init_arg => 'Checks',  required => 1, coerce => sub { [ map { Consul::API::Health::Check->new($_) } @{$_[0]} ] } );

1;
