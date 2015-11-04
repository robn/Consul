#!perl

use warnings;
use strict;

use Test::More;
use Test::Exception;
use Test::Consul;

use Consul;

my $tc = Test::Consul->start;

my $event = Consul->event(port => $tc->port);
ok $event, "got Event API object";

my $r;

lives_ok { $r = $event->list } "call to 'list' succeeded";
ok scalar @$r == 0, "no events";

lives_ok { $r = $event->fire("foo", payload => "bar") } "call to 'fire' with event 'foo' succeeded";
my $event_id = $r->id;

lives_ok { $r = $event->list } "call to 'list' succeeded";
ok scalar @$r == 1, "one event";
is $r->[0]->id, $event_id, "event has correct id";
is $r->[0]->name, "foo", "event has correct name";
is $r->[0]->payload, "bar", "event has correct payload";

done_testing;
