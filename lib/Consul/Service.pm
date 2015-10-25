package Consul::Service;

use namespace::autoclean;

use Moo;
use Types::Standard qw(Str Int ArrayRef);
use Carp qw(croak);
use JSON::MaybeXS qw(encode_json);

has name     => ( is => 'ro', isa => Str,           required => 1 );
has id       => ( is => 'ro', isa => Str );
has port     => ( is => 'ro', isa => Int );
has tags     => ( is => 'ro', isa => ArrayRef[Str], default => sub { [] } );
has script   => ( is => 'ro', isa => Str );
has interval => ( is => 'ro', isa => Str );
has ttl      => ( is => 'ro', isa => Str );

sub BUILD {
    my ($self) = @_;

    my $A = defined $self->script;
    my $B = defined $self->interval;
    my $C = defined $self->ttl;

    croak "Invalid check arguments, required: script, interval OR ttl"
        unless (!$A && !$B && !$C) || ($A && $B && !$C) || (!$A && !$B && $C)
}

sub to_json { shift->_json }
has _json => ( is => 'lazy', isa => Str );
sub _build__json {
    my ($self) = @_;
    encode_json({
        Name => $self->name,
        defined $self->id        ? ( ID       => $self->id       ) : (),
        defined $self->port      ? ( Notes    => $self->notes    ) : (),
        Tags => $self->tags,
        defined $self->script    ? ( Script   => $self->script   ) : (),
        defined $self->interval  ? ( Interval => $self->interval ) : (),
        defined $self->ttl       ? ( TTL      => $self->ttl      ) : (),
    });
}

1;
