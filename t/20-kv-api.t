#!perl

use warnings;
use strict;

use Test::More;
use Test::Exception;
use Test::Consul;

use Consul;

my $tc = Test::Consul->start;

my $kv = Consul->kv(port => $tc->port);
ok $kv, "got KV API object";

my $r;

throws_ok { $r = $kv->get("foo") } qr/^404 /, "key not found";

lives_ok { $r = $kv->put(foo => "bar") } "KV put succeeded";
lives_ok { $r = $kv->get("foo") } "KV get succeeded";

is $r->value, "bar", "returned KV has correct value";

lives_ok { $r = $kv->delete("foo") } "KV delete succeeded";
throws_ok { $r = $kv->get("foo") } qr/^404 /, "key not found";

lives_ok { $r = $kv->put(foo => 1) } "KV put succeeded";
lives_ok { $r = $kv->put(bar => 2) } "KV put succeeded";
lives_ok { $r = $kv->put(baz => 3) } "KV put succeeded";

lives_ok { $r = $kv->keys("") } "KV keys succeeded";
is_deeply [sort @$r], [sort qw(foo bar baz)], "return KV keys are correct";

done_testing;
