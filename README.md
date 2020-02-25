[![Build Status](https://secure.travis-ci.org/robn/Consul.png)](http://travis-ci.org/robn/Consul)

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

- `token`

    Consul ACL token.  This is used to set the `X-Consul-Token` HTTP header.  Typically
    Consul agents are pre-configured with a default ACL token, or ACLs are not enabled
    at all, so this option only needs to be set in certain cases.

- `request_cb`

    A callback to an alternative method to make the actual HTTP request. The
    callback is of the form:

        sub {
            my ($self, $req) = @_;
            ... do HTTP call
            $req->callback->(Consul::Response->new(...));
        }

    `$req` is a `Consul::Request` object, and has the following attributes:

    - `method`

        The HTTP method for the request.

    - `url`

        The complete URL to request. This is fully formed, and includes scheme, host,
        port and query parameters. You shouldn't need to touch it.

    - `headers`

        A [Hash::MultiValue](https://metacpan.org/pod/Hash%3A%3AMultiValue) object containing any headers that should be added to the
        request.

    - `content`

        The body content for the request.

    - `callback`

        A callback to call when the request is completed. It takes a single
        `Consul::Response` object as its parameter.

    - `args`

        A hashref containing the original arguments passed in to the endpoint method.

    The `callback` function should be called with a `Consul::Response` object
    containing the values returned by the Consul server in response to the request.
    Create one with `new`, passing the following attributes:

    - `status`

        The integer status code.

    - `reason`

        The status reason phrase.

    - `headers`

        A [Hash::MultiValue](https://metacpan.org/pod/Hash%3A%3AMultiValue) containing the response headers.

    - `content`

        Any body content returned in the response.

    - `request`

        The `Consul::Request` object passed to the callback.

    Consul itself provides a default `request_cb` that uses [HTTP::Tiny](https://metacpan.org/pod/HTTP%3A%3ATiny) to make
    calls to the server. If you provide one, you should honour the value of the
    `timeout` argument.

    `request_cb` can be used in conjunction with the `cb` option to all API method
    endpoints to get asynchronous behaviour. It's recommended however that you
    don't use this directly, but rather use a module like [AnyEvent::Consul](https://metacpan.org/pod/AnyEvent%3A%3AConsul) to
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

Key/value store API. See [Consul::API::KV](https://metacpan.org/pod/Consul%3A%3AAPI%3A%3AKV).

## agent

Agent API. See [Consul::API::Agent](https://metacpan.org/pod/Consul%3A%3AAPI%3A%3AAgent).

## catalog

Catalog (nodes and services) API. See [Consul::API::Catalog](https://metacpan.org/pod/Consul%3A%3AAPI%3A%3ACatalog).

## health

Health check API. See [Consul::API::Health](https://metacpan.org/pod/Consul%3A%3AAPI%3A%3AHealth).

## session

Sessions API. See [Consul::API::Session](https://metacpan.org/pod/Consul%3A%3AAPI%3A%3ASession).

## acl

Access control API. See [Consul::API::ACL](https://metacpan.org/pod/Consul%3A%3AAPI%3A%3AACL).

## event

User event API. See [Consul::API::Event](https://metacpan.org/pod/Consul%3A%3AAPI%3A%3AEvent).

## status

System status API. See [Consul::API::Status](https://metacpan.org/pod/Consul%3A%3AAPI%3A%3AStatus).

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

    `error_cb`

    A callback to an alternative method to handle internal errors (usually HTTP
    errors).  errors). The callback is of the form:

        sub {
            my ($err) = @_;
            ... output $err ...
        }

    The default callback calls the `error_cb` for the API object itself, which by
    default, simply calls croak.

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

- [AnyEvent::Consul](https://metacpan.org/pod/AnyEvent%3A%3AConsul) - a wrapper providing asynchronous operation
- [https://www.consul.io/docs/agent/http.html](https://www.consul.io/docs/agent/http.html) - Consul HTTP API documentation

# SUPPORT

## Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at [https://github.com/robn/Consul/issues](https://github.com/robn/Consul/issues).
You will be notified automatically of any progress on your issue.

## Source Code

This is open source software. The code repository is available for
public review and contribution under the terms of the license.

[https://github.com/robn/Consul](https://github.com/robn/Consul)

    git clone https://github.com/robn/Consul.git

# CONTRIBUTORS

- Rob N ★ <robn@robn.io>
- Aran Deltac <bluefeet@gmail.com>
- Michael McClimon

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Rob N ★.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
