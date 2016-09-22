#!perl

use warnings;
use strict;

use Test::More;
use Test::Exception;
use Test::Consul 0.005;

use Consul;

Test::Consul->skip_all_if_no_bin;

my $tc = Test::Consul->start;

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

done_testing;
