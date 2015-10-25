package Consul::Check;

use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str HashRef);

has name  => ( is => 'ro', isa => Str, required => 1 );
has id    => ( is => 'ro', isa => Str );
has notes => ( is => 'ro', isa => Str );

sub _to_json_hash { %{shift->_json_hash} }
has _json_hash => ( is => 'lazy', isa => HashRef[Str] );
sub _build__json_hash {
    my ($self) = @_;
    {
        Name => $self->name,
        defined $self->id    ? ( ID    => $self->id    ) : (),
        defined $self->notes ? ( Notes => $self->notes ) : (),
    };
}

package Consul::Check::Script;

use Moo;
use Types::Standard qw(Str);
use JSON::MaybeXS qw(encode_json);

has script   => ( is => 'ro', isa => Str, required => 1 );
has interval => ( is => 'ro', isa => Str, required => 1 );

sub to_json { shift->_json }
has _json => ( is => 'lazy', isa => Str );
sub _build__json {
    my ($self) = @_;
    encode_json({
        $self->_to_json_hash,
        Script   => $self->script,
        Interval => $self->interval,
    });
}

with qw(Consul::Check);

package Consul::Check::TTL;

use Moo;
use Types::Standard qw(Str);
use JSON::MaybeXS qw(encode_json);

has ttl => ( is => 'ro', isa => Str, required => 1 );

sub to_json { shift->_json }
has _json => ( is => 'lazy', isa => Str );
sub _build__json {
    my ($self) = @_;
    encode_json({
        $self->_to_json_hash,
        TTL => $self->ttl,
    });
}

with qw(Consul::Check);

1;
