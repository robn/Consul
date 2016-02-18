#!perl

use warnings;
use strict;

use Test::More;
use Test::Exception;

use Consul;

{
    my $agent = Consul->agent;
    ok $agent, "got Agent API object";

    dies_ok { $agent->members } "failing call with no error callback dies";
}

{
    my $global_error = 0;
    my $agent = Consul->agent(error_cb => sub { $global_error++ });
    ok $agent, "got Agent API object with global error callback";

    lives_ok { $agent->members } "failing call with global error callback succeeds";
    ok $global_error, "global error callback was called";
}

done_testing;
