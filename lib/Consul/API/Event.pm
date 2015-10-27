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

package
    Consul::API::Event::Impl; # hide from PAUSE

use Moo;

use JSON::MaybeXS;
use Carp qw(croak);

sub fire {
    my ($self, $name, %args) = @_;
    croak 'usage: $event->fire($name, [%args])' if grep { !defined } ($name);
    my $payload = delete $args{payload};
    Consul::API::Event::Event->new(decode_json($$self->api_exec($$self->_event_endpoint."/fire/".$name, 'PUT', %args, ($payload ? (_content => $payload) : ()))->{content}));
}

sub list {
    my ($self, %args) = @_;
    map { Consul::API::Event::Event->new(%$_) } @{decode_json($$self->api_exec($$self->_event_endpoint."/list", 'GET', %args)->{content})};
}

package Consul::API::Event::Event;

use Convert::Base64 qw(decode_base64);

use Moo;
use Types::Standard qw(Str Int Maybe);

has id             => ( is => 'ro', isa => Str,        init_arg => 'ID',            required => 1 );
has name           => ( is => 'ro', isa => Str,        init_arg => 'Name',          required => 1 );
has payload        => ( is => 'ro', isa => Maybe[Str], init_arg => 'Payload',       required => 1, coerce => sub { defined $_[0] ? decode_base64($_[0]) : undef});
has node_filter    => ( is => 'ro', isa => Str,        init_arg => 'NodeFilter',    required => 1 );
has service_filter => ( is => 'ro', isa => Str,        init_arg => 'ServiceFilter', required => 1 );
has tag_filter     => ( is => 'ro', isa => Str,        init_arg => 'TagFilter',     required => 1 );
has version        => ( is => 'ro', isa => Int,        init_arg => 'Version',       required => 1 );
has l_time         => ( is => 'ro', isa => Int,        init_arg => 'LTime',         required => 1 );

1;
