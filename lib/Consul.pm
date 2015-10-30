package Consul;

# ABSTRACT: Client library for consul

use namespace::autoclean;

use HTTP::Tiny 0.014;
use URI::Escape qw(uri_escape);
use Carp qw(croak);

use Moo;
use Type::Utils qw(class_type);
use Types::Standard qw(Str Int Bool HashRef);

has host => ( is => 'ro', isa => Str, default => '127.0.0.1' );
has port => ( is => 'ro', isa => Int, default => 8500 );

has ssl => ( is => 'ro', isa => Bool, default => 0 );

has http => ( is => 'lazy', isa => class_type('HTTP::Tiny') );
sub _build_http { HTTP::Tiny->new(timeout => 5) };

has version_prefix => ( is => 'ro', isa => Str, default => '/v1' );

has _url_base => ( is => 'lazy' );
sub _build__url_base {
    my ($self) = @_;
    ($self->ssl ? 'https' : 'http') .'://'.$self->host.':'.$self->port;
}

sub _prep_url {
    my ($self, $path, %args) = @_;
    my $trailing = $path =~ m{/$};
    my $url = $self->_url_base.join('/', map { uri_escape($_) } split('/', $path));
    $url .= '/' if $trailing;
    $url .= '?'.$self->http->www_form_urlencode(\%args) if %args;
    $url;
}

sub api_exec {
    my ($self, $path, $method, %args) = @_;
    my $content = delete $args{_content};
    delete $args{$_} for grep { m/^_/ } keys %args;
    my $res = $self->http->request($method, $self->_prep_url($path, %args), defined $content ? { content => $content } : {});
    return $res if $res->{success};
    croak "$res->{status} $res->{reason}: $res->{content}";
}

with qw(
    Consul::API::ACL
    Consul::API::Agent
    Consul::API::Catalog
    Consul::API::Event
    Consul::API::Health
    Consul::API::KV
    Consul::API::Session
    Consul::API::Status
);

use Consul::Check;
use Consul::Service;

1;

=pod

=encoding UTF-8

=head1 NAME

Consul - Client library for consul

=head1 SYNOPSIS

    use Consul;
    
    my $consul = Consul->new;
    say $consul->status->leader;
    
    # shortcut to single API
    my $status = Consul->status;
    say $status->leader;

=head1 DESCRIPTION

This is a client library for accessing and manipulating data in a Consul
cluster. It targets the Consul v1 HTTP API.

This module is quite low-level. You're expected to have a good understanding of
Consul and its API to understand the methods this module provides. See L</SEE ALSO>
for further reading.

=head1 CONSTRUCTOR

=head2 new

    my $consul = Consul->new( %args );

This constructor returns a new Consul client object. Valid arguments include:

=over 4

=item *

C<host>

Hostname or IP address of an Consul server (default: C<127.0.0.1>)

=item *

C<port>

Port where the etcd server is listening (default: C<8500>)

=item *

C<ssl>

Use SSL/TLS (ie HTTPS) when talking to the etcd server (default: off)

=item *

C<http>

A C<HTTP::Tiny> object to use to access the server. If not specified, one will
be created.

=head1 ENDPOINTS

Individual API endpoints are implemented in separate modules. The following
methods will return a context objects for the named API. Alternatively, you can
request an API context directly from the Consul package. In that case,
C<Consul-E<gt>new> is called implicitly.

    # these are equivalent
    my $agent = Consul->new( %args )->agent;
    my $agent = Consul->agent( %args );

=head2 kv

Key/Value store API. See L<Consul::API::KV>.

=head2 agent

Agent API. See L<Consul::API::Agent>.

=head2 catalog

Catalog (nodes and services) API. See L<Consul::API::Catalog>.

=head2 health

Health check API. See L<Consul::API::Health>.

=head2 session

Sessions API. See L<Consul::API::Session>.

=head2 acl

Access Control List API. See L<Consul::API::ACL>.

=head2 event

User Event API. See L<Consul::API::Event>.

=head2 status

System status API. See L<Consul::API::Status>.

=head1 SEE ALSO

=over 4

=item *

L<HTTP::Tiny> - for further HTTP client configuration, especially SSL configuration

=item *

L<https://www.consul.io/docs/agent/http.html> - Consul HTTP API documentation

=back

=head1 SUPPORT

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at L<https://github.com/robn/p5-consul/issues>.
You will be notified automatically of any progress on your issue.

=head2 Source Code

This is open source software. The code repository is available for
public review and contribution under the terms of the license.

L<https://github.com/robn/p5-consul>

  git clone https://github.com/robn/p5-consul.git

=head1 AUTHORS

=over 4

=item *

Robert Norris <rob@eatenbyagrue.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Robert Norris.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
