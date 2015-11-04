#!perl

use warnings;
use strict;

use Test::More;
use Test::Exception;
use Test::Consul;

use Consul;

my $tc = Test::Consul->start;

my $status = Consul->status(port => $tc->port);
ok $status, "got status API object";

lives_ok { $status->leader } "call to 'leader' succeeded";
lives_ok { $status->peers } "call to 'peers' succeeded";

done_testing;
