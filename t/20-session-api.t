#!perl

use warnings;
use strict;

use Test::More;
use Test::Exception;
use Test::Consul;

use Consul;

my $tc = eval { Test::Consul->start };

SKIP: {
    skip "consul test environment not available", 6 unless $tc;

    my $session = Consul->session(port => $tc->port);
    ok $session, "got Session API object";

    TODO: {
        local $TODO = "Consul::API::Session not yet implemented";

        lives_ok { $session->create } "call to 'create' succeeded";
        lives_ok { $session->destroy } "call to 'destroy' succeeded";
        lives_ok { $session->info } "call to 'info' succeeded";
        lives_ok { $session->node } "call to 'node' succeeded";
        lives_ok { $session->list } "call to 'list' succeeded";
    }
}

done_testing;
