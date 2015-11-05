package Consul::API::KV;

use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str);

requires qw(_version_prefix _api_exec);

has _kv_endpoint => ( is => 'lazy', isa => Str );
sub _build__kv_endpoint {
    shift->_version_prefix . '/kv';
}

sub kv {
    my $self = shift;
    $self = Consul->new(@_) unless ref $self;
    return bless \$self, "Consul::API::KV::Impl";
}

package
    Consul::API::KV::Impl; # hide from PAUSE

use Moo;

use Carp qw(croak);

sub get {
    my ($self, $key, %args) = @_;
    croak 'usage: $kv->get($key, [%args])' if grep { !defined } ($key);
    Consul::API::KV::Response->new($$self->_api_exec($$self->_kv_endpoint."/".$key, 'GET', %args)->[0]);
}

sub put {
    my ($self, $key, $value, %args) = @_;
    croak 'usage: $kv->put($key, $value, [%args])' if grep { !defined } ($key, $value);
    $$self->_api_exec($$self->_kv_endpoint."/".$key, 'PUT', %args, _content => $value);
}

sub delete {
    my ($self, $key, %args) = @_;
    croak 'usage: $kv->delete($key, [%args])' if grep { !defined } ($key);
    $$self->_api_exec($$self->_kv_endpoint."/".$key, 'DELETE', %args);
    return;
}

sub keys {
    my ($self, $key, %args) = @_;
    croak 'usage: $kv->keys($key, [%args])' if grep { !defined } ($key);
    $$self->_api_exec($$self->_kv_endpoint."/".$key, 'GET', %args, keys => 1);
}

package Consul::API::KV::Response;

use Convert::Base64 qw(decode_base64);

use Moo;
use Types::Standard qw(Str Int);

has key          => ( is => 'ro', isa => Str, init_arg => 'Key',         required => 1 );
has value        => ( is => 'ro', isa => Str, init_arg => 'Value',       required => 1, coerce => sub { decode_base64($_[0]) });
has flags        => ( is => 'ro', isa => Int, init_arg => 'Flags',       required => 1 );
has session      => ( is => 'ro', isa => Str, init_arg => 'Session' );
has create_index => ( is => 'ro', isa => Int, init_arg => 'CreateIndex', required => 1 );
has modify_index => ( is => 'ro', isa => Int, init_arg => 'ModifyIndex', required => 1 );
has lock_index   => ( is => 'ro', isa => Int, init_arg => 'LockIndex',   required => 1 );

1;

=pod

=encoding UTF-8

=head1 NAME

Consul::API::KV - Key/value store API

=head1 SYNOPSIS

    use Consul;
    my $kv = Consul->kv;

=head1 DESCRIPTION

The KV API is used to access Consul's simple key/value store, useful for storing service configuration or other metadata.

This API is fully documented at L<https://www.consul.io/docs/agent/http/kv.html>.

=head1 METHODS

=head2 get

=head2 put

=head2 delete

=head2 keys

=head1 SEE ALSO

    L<Consul>

=cut
