package Consul::API::Status;

use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str);

requires qw(version_prefix api_exec);

has _status_endpoint => ( is => 'lazy', isa => Str );
sub _build__status_endpoint {
    shift->version_prefix . '/status';
}

sub status {
    my ($self) = @_;
    return bless \$self, "Consul::API::Status::Impl";
}

package Consul::API::Status::Impl;

use Moo;

use JSON::MaybeXS qw(decode_json);
use Carp qw(croak);

sub leader {
    my ($self, %args) = @_;
    # returns raw JSON string, so need alternate decoder
    JSON->new->utf8->allow_nonref->decode($$self->api_exec($$self->_status_endpoint."/leader", "GET", %args)->{content});
}

sub peers {
    my ($self, %args) = @_;
    @{decode_json($$self->api_exec($$self->_status_endpoint."/peers", "GET", %args)->{content})};
}

1;
