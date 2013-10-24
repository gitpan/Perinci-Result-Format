#!perl

use 5.010;
use strict;
use warnings;
use Test::More 0.96;

use Perinci::Result::Format;

ok(!defined(Perinci::Result::Format::format([200, "OK"], 'foo')),
   "unknown format -> undef");
is(Perinci::Result::Format::format([200, "OK"], 'text-simple'),
   "",
   "text: envelope removed when 200");
is(Perinci::Result::Format::format([200, "OK", "a"], 'text-simple'),
   "a\n",
   "text: envelope removed when 200 (2, newline appended)");
is(Perinci::Result::Format::format([200, "OK", "a\n"], 'text-simple'),
   "a\n",
   "text: envelope removed when 200 (3)");
is(Perinci::Result::Format::format([200, "OK", {val=>1}], 'phpserialization'),
   q(a:3:{i:0;i:200;i:1;s:2:"OK";i:2;a:1:{s:3:"val";i:1;}}),
   "phpserialization format");
{
    local $ENV{COLOR} = 0;
    is(Perinci::Result::Format::format([400, "Foo"], 'text-simple'),
       "ERROR 400: Foo\n",
       "text: error message formatting");
}

{
    $ENV{COLOR} = 0;
    is(Perinci::Result::Format::format([200, "OK", ""], 'json'),
       '[200,"OK",""]',
       "json");
}

is($Perinci::Result::Format::Formats{json}[1],
   'application/json',
   'mime type 1');

# XXX test result metadata: result_format_options

done_testing();
