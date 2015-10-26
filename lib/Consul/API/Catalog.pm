package Consul::API::Catalog;

use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str);

requires qw(version_prefix api_exec);

has _catalog_endpoint => ( is => 'lazy', isa => Str );
sub _build__catalog_endpoint {
    shift->version_prefix . '/catalog';
}

sub catalog {
    my ($self) = @_;
    return bless \$self, "Consul::API::Catalog::Impl";
}

package
    Consul::API::Catalog::Impl; # hide from PAUSE

use Moo;

use JSON::MaybeXS;
use Carp qw(croak);

sub datacenters {
    my ($self, %args) = @_;
    @{decode_json($$self->api_exec($$self->_catalog_endpoint."/datacenters", 'GET', %args)->{content})};
}

sub nodes {
    my ($self, %args) = @_;
    map { Consul::API::Catalog::ShortNode->new(%$_) } @{decode_json($$self->api_exec($$self->_catalog_endpoint."/nodes", 'GET', %args)->{content})};
}

sub services {
    my ($self, %args) = @_;
    %{decode_json($$self->api_exec($$self->_catalog_endpoint."/services", 'GET', %args)->{content})};
}

sub service {
    my ($self, $service, %args) = @_;
    croak 'usage: $catalog->service($service, [%args])' if grep { !defined } ($service);
    map { Consul::API::Catalog::Service->new(%$_) } @{decode_json($$self->api_exec($$self->_catalog_endpoint."/service/".$service, 'GET', %args)->{content})};
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
    # node
    croak "not yet implemented";
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

1;
