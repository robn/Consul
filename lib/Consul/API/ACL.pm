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

=pod

=encoding UTF-8

=head1 NAME

Consul::API::ACL - Consul ACL API

=head1 SYNOPSIS

    use Consul;
    my $acl = Consul->acl;

=head1 DESCRIPTION

The ACL API is used to create, update, destroy, and query ACL tokens.

This API is fully documented at L<https://www.consul.io/docs/agent/http/acl.html>.

=head1 METHODS

=head2 create

=head2 update

=head2 destroy

=head2 info

=head2 clone

=head2 list

=head1 SEE ALSO

    L<Consul>

=cut
