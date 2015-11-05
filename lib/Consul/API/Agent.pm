package Consul::API::Agent;

use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str);

requires qw(_version_prefix _api_exec);

has _agent_endpoint => ( is => 'lazy', isa => Str );
sub _build__agent_endpoint {
    shift->_version_prefix . '/agent';
}

sub agent {
    my $self = shift;
    $self = Consul->new(@_) unless ref $self;
    return bless \$self, "Consul::API::Agent::Impl";
}

package
    Consul::API::Agent::Impl; # hide from PAUSE

use Moo;

use Carp qw(croak);

sub checks {
    my ($self, %args) = @_;
    [ map { Consul::API::Agent::Check->new(%$_) } values %{$$self->_api_exec($$self->_agent_endpoint."/checks", 'GET', %args)} ];
}

sub services {
    my ($self, %args) = @_;
    [ map { Consul::API::Agent::Service->new(%$_) } values %{$$self->_api_exec($$self->_agent_endpoint."/services", 'GET', %args)} ];
}

sub members {
    my ($self, %args) = @_;
    [ map { Consul::API::Agent::Member->new(%$_) } @{$$self->_api_exec($$self->_agent_endpoint."/members", 'GET', %args)} ];
}

sub self {
    my ($self, %args) = @_;
    Consul::API::Agent::Self->new(%{$$self->_api_exec($$self->_agent_endpoint."/self", 'GET', %args)});
}

sub maintenance {
    my ($self, $enable, %args) = @_;
    croak 'usage: $agent->maintenance($enable, [%args])' if grep { !defined } ($enable);
    $$self->_api_exec($$self->_agent_endpoint."/maintenance", 'PUT', enable => ($enable ? "true" : "false"), %args);
    return;
}

sub join {
    my ($self, $address, %args) = @_;
    croak 'usage: $agent->join($address, [%args])' if grep { !defined } ($address);
    $$self->_api_exec($$self->_agent_endpoint."/join/".$address, 'GET', %args);
    return;
}

sub force_leave {
    my ($self, $node, %args) = @_;
    croak 'usage: $agent->force_leave($node, [%args])' if grep { !defined } ($node);
    $$self->_api_exec($$self->_agent_endpoint."/force-leave/".$node, 'GET', %args);
    return;
}

sub register_check {
    my ($self, $check, %args) = @_;
    croak 'usage: $agent->register_check($check, [%args])' if grep { !defined } ($check);
    $$self->_api_exec($$self->_agent_endpoint."/check/register", 'PUT', %args, _content => $check->to_json);
    return;
}

sub deregister_check {
    my ($self, $check_id, %args) = @_;
    croak 'usage: $agent->deregister_check($check_id, [%args])' if grep { !defined } ($check_id);
    $$self->_api_exec($$self->_agent_endpoint."/check/deregister/".$check_id, 'GET', %args);
    return;
}

sub pass_check {
    my ($self, $check_id, %args) = @_;
    croak 'usage: $agent->pass_check($check_id, [%args])' if grep { !defined } ($check_id);
    $$self->_api_exec($$self->_agent_endpoint."/check/pass/".$check_id, 'GET', %args);
    return;
}

sub warn_check {
    my ($self, $check_id, %args) = @_;
    croak 'usage: $agent->warn_check($check_id, [%args])' if grep { !defined } ($check_id);
    $$self->_api_exec($$self->_agent_endpoint."/check/warn/".$check_id, 'GET', %args);
    return;
}

sub fail_check {
    my ($self, $check_id, %args) = @_;
    croak 'usage: $agent->fail_check($check_id, [%args])' if grep { !defined } ($check_id);
    $$self->_api_exec($$self->_agent_endpoint."/check/fail/".$check_id, 'GET', %args);
    return;
}

sub service_register {
    my ($self, $service, %args) = @_;
    croak 'usage: $agent->service_register($service, [%args])' if grep { !defined } ($service);
    $$self->_api_exec($$self->_agent_endpoint."/service/register", 'PUT', %args, _content => $service->to_json);
    return;
}

sub service_deregister {
    my ($self, $service_id, %args) = @_;
    croak 'usage: $agent->service_deregister($check_id, [%args])' if grep { !defined } ($service_id);
    $$self->_api_exec($$self->_agent_endpoint."/service/deregister/".$service_id, 'GET', %args);
    return;
}

sub service_maintenance {
    my ($self, $service_id, $enable, %args) = @_;
    croak 'usage: $agent->service_maintenance($service_id, $enable, [%args])' if grep { !defined } ($service_id, $enable);
    $$self->_api_exec($$self->_agent_endpoint."/service/maintenance/".$service_id, 'PUT', enable => ($enable ? "true" : "false"), %args);
    return;
}

package Consul::API::Agent::Check;

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

package Consul::API::Agent::Service;

use Moo;
use Types::Standard qw(Str Int ArrayRef);

has id      => ( is => 'ro', isa => Str,           init_arg => 'ID',      required => 1 );
has service => ( is => 'ro', isa => Str,           init_arg => 'Service', required => 1 );
has address => ( is => 'ro', isa => Str,           init_arg => 'Address', required => 1 );
has port    => ( is => 'ro', isa => Int,           init_arg => 'Port',    required => 1 );
has tags    => ( is => 'ro', isa => ArrayRef[Str], init_arg => 'Tags',    required => 1, coerce => sub { $_[0] // [] } );

package Consul::API::Agent::Member;

use Moo;
use Types::Standard qw(Str Int HashRef);

has name         => ( is => 'ro', isa => Str,          init_arg => 'Name',        required => 1 );
has addr         => ( is => 'ro', isa => Str,          init_arg => 'Addr',        required => 1 );
has port         => ( is => 'ro', isa => Int,          init_arg => 'Port',        required => 1 );
has tags         => ( is => 'ro', isa => HashRef[Str], init_arg => 'Tags',        required => 1, coerce => sub { $_[0] // {} } );
has status       => ( is => 'ro', isa => Int,          init_arg => 'Status',      required => 1 );
has protocol_min => ( is => 'ro', isa => Int,          init_arg => 'ProtocolMin', required => 1 );
has protocol_max => ( is => 'ro', isa => Int,          init_arg => 'ProtocolMax', required => 1 );
has protocol_cur => ( is => 'ro', isa => Int,          init_arg => 'ProtocolCur', required => 1 );
has delegate_min => ( is => 'ro', isa => Int,          init_arg => 'DelegateMin', required => 1 );
has delegate_max => ( is => 'ro', isa => Int,          init_arg => 'DelegateMax', required => 1 );
has delegate_cur => ( is => 'ro', isa => Int,          init_arg => 'DelegateCur', required => 1 );

package Consul::API::Agent::Self;

use Moo;
use Types::Standard qw(HashRef);
use Type::Utils qw(class_type);

# XXX raw hash. not happy about this, but the list of config keys don't seem to be consistent across environments
has config => ( is => 'ro', isa => HashRef,                                  init_arg => 'Config', required => 1, coerce => sub { $_[0] // {} } );
has member => ( is => 'ro', isa => class_type('Consul::API::Agent::Member'), init_arg => 'Member', required => 1, coerce => sub { Consul::API::Agent::Member->new($_[0]) } );

1;
