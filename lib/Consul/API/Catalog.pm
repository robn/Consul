package Consul::API::Catalog;

use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str);

requires qw(_version_prefix _api_exec);

has _catalog_endpoint => ( is => 'lazy', isa => Str );
sub _build__catalog_endpoint {
    shift->_version_prefix . '/catalog';
}

sub catalog {
    my $self = shift;
    $self = Consul->new(@_) unless ref $self;
    return bless \$self, "Consul::API::Catalog::Impl";
}

package
    Consul::API::Catalog::Impl; # hide from PAUSE

use Moo;

use Carp qw(croak);

sub datacenters {
    my ($self, %args) = @_;
    $$self->_api_exec($$self->_catalog_endpoint."/datacenters", 'GET', %args);
}

sub nodes {
    my ($self, %args) = @_;
    [ map { Consul::API::Catalog::ShortNode->new(%$_) } @{$$self->_api_exec($$self->_catalog_endpoint."/nodes", 'GET', %args)} ];
}

# XXX return hashref
sub services {
    my ($self, %args) = @_;
    %{$$self->_api_exec($$self->_catalog_endpoint."/services", 'GET', %args)};
}

sub service {
    my ($self, $service, %args) = @_;
    croak 'usage: $catalog->service($service, [%args])' if grep { !defined } ($service);
    [ map { Consul::API::Catalog::Service->new(%$_) } @{$$self->_api_exec($$self->_catalog_endpoint."/service/".$service, 'GET', %args)} ];
}

sub register {
    # register
    croak "not yet implemented";
}

sub deregister {
    # deregister
    croak "not yet implemented";
}

sub node {
    my ($self, $node, %args) = @_;
    croak 'usage: $catalog->node($node, [%args])' if grep { !defined } ($node);
    Consul::API::Catalog::Node->new($$self->_api_exec($$self->_catalog_endpoint."/node/".$node, 'GET', %args));
}

package Consul::API::Catalog::ShortNode;

use Moo;
use Types::Standard qw(Str);

has name    => ( is => 'ro', isa => Str, init_arg => 'Node',    required => 1 );
has address => ( is => 'ro', isa => Str, init_arg => 'Address', required => 1 );

package Consul::API::Catalog::Service;

use Moo;
use Types::Standard qw(Str Int ArrayRef);

has name    => ( is => 'ro', isa => Str,           init_arg => 'ServiceName', required => 1 );
has id      => ( is => 'ro', isa => Str,           init_arg => 'ServiceID',   required => 1 );
has port    => ( is => 'ro', isa => Int,           init_arg => 'ServicePort', required => 1 );
has node    => ( is => 'ro', isa => Str,           init_arg => 'Node',        required => 1 );
has address => ( is => 'ro', isa => Str,           init_arg => 'Address',     required => 1 );
has tags    => ( is => 'ro', isa => ArrayRef[Str], init_arg => 'ServiceTags', required => 1, coerce => sub { $_[0] // [] } );

package Consul::API::Catalog::Node;

use Moo;
use Types::Standard qw(HashRef);
use Type::Utils qw(class_type);

has node     => ( is => 'ro', isa => class_type('Consul::API::Catalog::ShortNode'),      init_arg => 'Node',     required => 1, coerce => sub { Consul::API::Catalog::ShortNode->new($_[0]) } );
has services => ( is => 'ro', isa => HashRef[class_type('Consul::API::Agent::Service')], init_arg => 'Services', required => 1, coerce => sub { +{ map { $_ => Consul::API::Agent::Service->new($_[0]->{$_}) } keys %{$_[0]} } } );

1;
