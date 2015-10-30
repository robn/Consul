package Consul::API::ACL;

use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str);

requires qw(_version_prefix _api_exec);

has _acl_endpoint => ( is => 'lazy', isa => Str );
sub _build__acl_endpoint {
    shift->_version_prefix . '/acl';
}

sub acl {
    my $self = shift;
    $self = Consul->new(@_) unless ref $self;
    return bless \$self, "Consul::API::ACL::Impl";
}

package
    Consul::API::ACL::Impl; # hide from PAUSE

use Moo;

use Carp qw(croak);

sub create {
    # create
    croak "not yet implemented";
}

sub update {
    # update
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

sub clone {
    # clone
    croak "not yet implemented";
}

sub list {
    # list
    croak "not yet implemented";
}

1;
