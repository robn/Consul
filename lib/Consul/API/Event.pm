package Consul::API::Event;

use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str);

requires qw(version_prefix api_exec);

has _event_endpoint => ( is => 'lazy', isa => Str );
sub _build__event_endpoint {
    shift->version_prefix . '/event';
}

sub event {
    my ($self) = @_;
    return bless \$self, "Consul::API::Event::Impl";
}

package Consul::API::Event::Impl;

use Moo;

use JSON::MaybeXS;
use Carp qw(croak);

sub fire {
    # fire
    croak "not yet implemented";
}

sub list {
    # list
    croak "not yet implemented";
}

1;
