package Consul::API::Session;

use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str);

requires qw(version_prefix api_exec);

has _session_endpoint => ( is => 'lazy', isa => Str );
sub _build__session_endpoint {
    shift->version_prefix . '/session';
}

sub session {
    my ($self) = @_;
    return bless \$self, "Consul::API::Session::Impl";
}

package
    Consul::API::Session::Impl; # hide from PAUSE

use Moo;

use JSON::MaybeXS;
use Carp qw(croak);

sub create {
    # create
    croak "not yet implemented";
}

sub destroy {
    # destroy
    croak "not yet implemented";
}

sub info {
    # info
    croak "not yet implemented";
}

sub node {
    # node
    croak "not yet implemented";
}

sub list {
    # list
    croak "not yet implemented";
}

1;
