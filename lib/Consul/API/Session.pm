package Consul::API::Session;

use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str);

requires qw(_version_prefix _api_exec);

has _session_endpoint => ( is => 'lazy', isa => Str );
sub _build__session_endpoint {
    shift->_version_prefix . '/session';
}

sub session {
    my $self = shift;
    $self = Consul->new(@_) unless ref $self;
    return bless \$self, "Consul::API::Session::Impl";
}

package
    Consul::API::Session::Impl; # hide from PAUSE

use Moo;

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

=pod

=encoding UTF-8

=head1 NAME

Consul::API::Session - Sessions API

=head1 SYNOPSIS

    use Consul;
    my $session = Consul->session;

=head1 DESCRIPTION

The Session API is used to create, destroy, and query sessions.

This API is fully documented at L<https://www.consul.io/docs/agent/http/session.html>.

=head1 METHODS

=head2 create

=head2 destroy

=head2 info

=head2 node

=head2 list

=head1 SEE ALSO

    L<Consul>

=cut
