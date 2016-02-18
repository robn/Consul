#!perl

use warnings;
use strict;

use Test::More;
use Test::Exception;
use Test::Consul 0.003;

use Consul;

my $tc = eval { Test::Consul->start };

SKIP: {
    skip "consul test environment not available", 7 unless $tc;

    my $acl = Consul->acl(port => $tc->port);
    ok $acl, "got ACL API object";

    TODO: {
        local $TODO = "Consul::API::ACL not yet implemented";

        lives_ok { $acl->create } "call to 'create' succeeded";
        lives_ok { $acl->update } "call to 'update' succeeded";
        lives_ok { $acl->destroy } "call to 'destroy' succeeded";
        lives_ok { $acl->info } "call to 'info' succeeded";
        lives_ok { $acl->clone } "call to 'clone' succeeded";
        lives_ok { $acl->list } "call to 'list' succeeded";
    }
}

done_testing;
