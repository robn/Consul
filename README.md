# NAME

Consul - Client library for consul

# SYNOPSIS

    use Consul;
    
    my $consul = Consul->new;
    say $consul->status->leader;
    
    # shortcut to single API
    my $status = Consul->status;
    say $status->leader;

# DESCRIPTION

This is a client library for accessing and manipulating data in a Consul
cluster. It targets the Consul v1 HTTP API.

This module is quite low-level. You're expected to have a good understanding of
Consul and its API to understand the methods this module provides. See ["SEE ALSO"](#see-also)
for further reading.

# WARNING

This is still under development. The documentation isn't all there yet (in
particular about the return types) and a couple of APIs aren't implemented.
It's still very useful and I don't expect huge changes, but please take care
when upgrading. Open an issue if there's something you need that isn't here and
I'll get right on it!

# CONSTRUCTOR

## new

    my $consul = Consul->new( %args );

This constructor returns a new Consul client object. Valid arguments include:

- `host`

    Hostname or IP address of an Consul server (default: `127.0.0.1`)

- `port`

    Port where the Consul server is listening (default: `8500`)

- `ssl`

    Use SSL/TLS (ie HTTPS) when talking to the Consul server (default: off)

- `timeout`

    Request timeout. If a request to Consul takes longer that this, the endpoint
    method will fail (default: 15).

- `request_cb`

    A callback to an alternative method to make the actual HTTP request. The
    callback is of the form:

        sub {
            my ($self, $method, $url, $content, $cb) = @_;
            ... do HTTP call
            $cb->($rstatus, $rreason, $rcontent);
        }

    In other words, make a request to `$url` using HTTP method `$method`, with
    `$content` in the request body, adding in the headers from `$headers`. Call
    `$cb` with the returned status, reason, headers and body content.

    `$headers` is a [Hash::MultiValue](https://metacpan.org/pod/Hash::MultiValue). The returned headers must also be one.

    Consul itself provides a default `request_cb` that uses [HTTP::Tiny](https://metacpan.org/pod/HTTP::Tiny) to make
    calls to the server. If you provide one, you should honour the value of the
    `timeout` argument.

    `request_cb` can be used in conjunction with the `cb` option to all API method
    endpoints to get asynchronous behaviour. It's recommended however that you
    don't use this directly, but rather use a module like [AnyEvent::Consul](https://metacpan.org/pod/AnyEvent::Consul) to
    take care of that for you.

    If you just want to use this module to make simple calls to your Consul
    cluster, you can ignore this option entirely.

- `error_cb`

    A callback to an alternative method to handle internal errors (usually HTTP
    errors). The callback is of the form:

        sub {
            my ($err) = @_;
            ... output $err ...
        }

    The default callback simply calls `croak`.

# ENDPOINTS

Individual API endpoints are implemented in separate modules. The following
methods will return a context objects for the named API. Alternatively, you can
request an API context directly from the Consul package. In that case,
`Consul->new` is called implicitly.

    # these are equivalent
    my $agent = Consul->new( %args )->agent;
    my $agent = Consul->agent( %args );

## kv

Key/value store API. See [Consul::API::KV](https://metacpan.org/pod/Consul::API::KV).

## agent

Agent API. See [Consul::API::Agent](https://metacpan.org/pod/Consul::API::Agent).

## catalog

Catalog (nodes and services) API. See [Consul::API::Catalog](https://metacpan.org/pod/Consul::API::Catalog).

## health

Health check API. See [Consul::API::Health](https://metacpan.org/pod/Consul::API::Health).

## session

Sessions API. See [Consul::API::Session](https://metacpan.org/pod/Consul::API::Session).

## acl

Access control API. See [Consul::API::ACL](https://metacpan.org/pod/Consul::API::ACL).

## event

User event API. See [Consul::API::Event](https://metacpan.org/pod/Consul::API::Event).

## status

System status API. See [Consul::API::Status](https://metacpan.org/pod/Consul::API::Status).

# METHOD OPTIONS

All API methods implemented by the endpoints can take a number of arguments.
Most of those are documented in the endpoint documentation. There are however
some that are common to all methods:

- `cb`

    A callback to call with the results of the method. Without this, the results
    are returned from the method, but only if `request_cb` is synchronous. If an
    asynchronous `request_cb` is used without a `cb` being passed to the method, the
    method return value is undefined.

    If you just want to use this module to make simple calls to your Consul
    cluster, you can ignore this option entirely.

# BLOCKING QUERIES

Some Consul API endpoints support a feature called a "blocking query". These
endpoints allow long-polling for changes, and support some extra information
about the server state, including the Raft index, in the response headers.

The corresponding endpoint methods, when called in array context, will return a
second value. This is an object with three methods, `index`, `last_contact`
and `known_leader`, corresponding to the similarly-named header fields. You
can use these to set up state watches, CAS writes, and so on.

See the Consul API docs for more information.

# SEE ALSO

- [HTTP::Tiny](https://metacpan.org/pod/HTTP::Tiny) - for further HTTP client configuration, especially SSL configuration
- [AnyEvent::Consul](https://metacpan.org/pod/AnyEvent::Consul) - a wrapper provided asynchronous operation
- [https://www.consul.io/docs/agent/http.html](https://www.consul.io/docs/agent/http.html) - Consul HTTP API documentation

# SUPPORT

## Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at [https://github.com/robn/p5-consul/issues](https://github.com/robn/p5-consul/issues).
You will be notified automatically of any progress on your issue.

## Source Code

This is open source software. The code repository is available for
public review and contribution under the terms of the license.

[https://github.com/robn/p5-consul](https://github.com/robn/p5-consul)

    git clone https://github.com/robn/p5-consul.git

# AUTHORS

- Robert Norris <rob@eatenbyagrue.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Robert Norris.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
