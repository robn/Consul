package Consul;

# ABSTRACT: Client library for consul

use namespace::autoclean;

use HTTP::Tiny 0.014;
use URI::Escape qw(uri_escape);
use JSON::MaybeXS qw(JSON);
use Hash::MultiValue;
use Carp qw(croak);

use Moo;
use Type::Utils qw(class_type);
use Types::Standard qw(Str Int Bool HashRef CodeRef);

has host => ( is => 'ro', isa => Str, default => sub { '127.0.0.1' } );
has port => ( is => 'ro', isa => Int, default => sub { 8500 } );

has ssl => ( is => 'ro', isa => Bool, default => sub { 0 } );

has http => ( is => 'lazy', isa => class_type('HTTP::Tiny') );
sub _build_http { HTTP::Tiny->new(timeout => 15) };

has _version_prefix => ( is => 'ro', isa => Str, default => sub { '/v1' } );

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

my $json = JSON->new->utf8->allow_nonref;

sub _prep_request {
    my ($self, $path, $method, %args) = @_;

    my %uargs = map { m/^_/ ? () : ($_ => $args{$_}) } keys %args;

    my $headers = Hash::MultiValue->new;

    return ($method, $self->_prep_url($path, %uargs), $headers, $args{_content});
}

sub _prep_response {
    my ($self, $status, $reason, $headers, $content, %args) = @_;

    my $valid_cb = $args{_valid_cb} // sub { int($_[0]/100) == 2 };

    croak "$status $reason: $content" unless $valid_cb->($status);

    return if !defined $content || length $content == 0;

    return $json->decode($content);
}

has req_cb => ( is => 'lazy', isa => CodeRef );
sub _build_req_cb {
    sub {
        my ($self, $method, $url, $headers, $content, $cb) = @_;
        my $res = $self->http->request($method, $url, {
            (defined $headers ? ( headers => $headers->mixed ) : ()),
            (defined $content ? ( content => $content ) : ()),
        });
        my $rheaders = Hash::MultiValue->from_mixed(delete $res->{headers} // {});
        my ($rstatus, $rreason, $rcontent) = @$res{qw(status reason content)};
        $cb->($rstatus, $rreason, $rheaders, $rcontent);
    }
}

sub _api_exec {
    my $resp_cb = $#_ % 2 == 1 && ref $_[$#_] eq 'CODE' ? pop @_ : sub { pop @_ };
    my ($self, $path, $method, %args) = @_;

    my $r;
    my $cli_cb = delete $args{cb} // sub { $r = shift };

    $self->req_cb->($self, $self->_prep_request($path, $method, %args), sub {
        my ($data, $meta) = $self->_prep_response(@_, %args);
        $cli_cb->($resp_cb->($data), $meta);
    });

    return $r;
};

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

=head1 WARNING

This is still under development. The documentation isn't all there yet (in
particular about the return types) and a couple of APIs aren't implemented.
It's still very useful and I don't expect huge changes, but please take care
when upgrading. Open an issue if there's something you need that isn't here and
I'll get right on it!

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

Port where the Consul server is listening (default: C<8500>)

=item *

C<ssl>

Use SSL/TLS (ie HTTPS) when talking to the Consul server (default: off)

=item *

C<http>

A C<HTTP::Tiny> object to use to access the server. If not specified, one will
be created.

=item *

C<req_cb>

A callback to an alternative method to make the actual HTTP request. The
callback is of the form:

    sub {
        my ($self, $method, $url, $content, $cb) = @_;
        ... do HTTP call
        $cb->($rstatus, $rreason, $rcontent);
    }

In other words, make a request to C<$url> using HTTP method C<$method>, with
C<$content> in the request body, adding in the headers from C<$headers>. Call
C<$cb> with the returned status, reason, headers and body content.

C<$headers> is a L<Hash::MultiValue>. The returned headers must also be one.

Consul itself provides a default C<req_cb> that uses the C<http> option to make
calls to the server. If you provide one, C<http> will not be used.

C<req_cb> can be used in conjunction with the C<cb> option to all API method
endpoints to get asynchronous behaviour. It's recommended however that you
don't use this directly, but rather use a module like L<AnyEvent::Consul> to
take care of that for you.

If you just want to use this module to make simple calls to your Consul
cluster, you can ignore this option entirely.

=back

=head1 ENDPOINTS

Individual API endpoints are implemented in separate modules. The following
methods will return a context objects for the named API. Alternatively, you can
request an API context directly from the Consul package. In that case,
C<Consul-E<gt>new> is called implicitly.

    # these are equivalent
    my $agent = Consul->new( %args )->agent;
    my $agent = Consul->agent( %args );

=head2 kv

Key/value store API. See L<Consul::API::KV>.

=head2 agent

Agent API. See L<Consul::API::Agent>.

=head2 catalog

Catalog (nodes and services) API. See L<Consul::API::Catalog>.

=head2 health

Health check API. See L<Consul::API::Health>.

=head2 session

Sessions API. See L<Consul::API::Session>.

=head2 acl

Access control API. See L<Consul::API::ACL>.

=head2 event

User event API. See L<Consul::API::Event>.

=head2 status

System status API. See L<Consul::API::Status>.

=head1 METHOD OPTIONS

All API methods implemented by the endpoints can take a number of arguments.
Most of those are documented in the endpoint documentation. There are however
some that are common to all methods:

=over 4

=item *

C<cb>

A callback to call with the results of the method. Without this, the results
are returned from the method, but only if C<req_cb> is synchronous. If an
asynchronous C<req_cb> is used without a C<cb> being passed to the method, the
method return value is undefined.

If you just want to use this module to make simple calls to your Consul
cluster, you can ignore this option entirely.

=back

=head1 SEE ALSO

=over 4

=item *

L<HTTP::Tiny> - for further HTTP client configuration, especially SSL configuration

=item *

L<AnyEvent::Consul> - a wrapper provided asynchronous operation

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
