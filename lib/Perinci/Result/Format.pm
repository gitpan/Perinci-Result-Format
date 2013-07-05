package Perinci::Result::Format;

use 5.010001;
use strict;
use warnings;

use Scalar::Util qw(reftype);

our $VERSION = '0.31'; # VERSION

our $Enable_Decoration = 1;
our $Enable_Cleansing  = 0;

# text formats are special. since they are more oriented towards human instead
# of machine, we remove envelope when status is 200, so users only see content.

my $format_text = sub {
    my ($format, $res) = @_;
    if (!defined($res->[2])) {
        return $res->[0] =~ /\A(?:200|304)\z/ ? "" :
            "ERROR $res->[0]: $res->[1]" .
                ($res->[1] =~ /\n\z/ ? "" : "\n");
    }
    my ($r, $opts);
    if ($res->[0] == 200) {
        $r = $res->[2];
        my $rfo = $res->[3]{result_format_options} // {};
        # old compat, rfo used to be only opts, now it's {fmt=>opts, ...}
        if ($rfo->{$format}) { $opts = $rfo->{$format} } else { $opts = $rfo }
    } else {
        $r = $res;
        $opts = {};
    }
    if ($format eq 'text') {
        return Data::Format::Pretty::format_pretty(
            $r, {%$opts, module=>'Console'});
    }
    if ($format eq 'text-simple') {
        return Data::Format::Pretty::format_pretty(
            $r, {%$opts, module=>'SimpleText'});
    }
    if ($format eq 'text-pretty') {
        return Data::Format::Pretty::format_pretty(
            $r, {%$opts, module=>'Text'});
    }
};

our %Formats = (
    yaml          => ['YAML', 'text/yaml', {circular=>1}],
    json          => ['CompactJSON', 'application/json', {circular=>0}],
    'json-pretty' => ['JSON', 'application/json', {circular=>0}],
    text          => [$format_text, 'text/plain', {circular=>0}],
    'text-simple' => [$format_text, 'text/plain', {circular=>0}],
    'text-pretty' => [$format_text, 'text/plain', {circular=>0}],
);

sub format {
    require Data::Format::Pretty;

    my ($res, $format) = @_;

    my $fmtinfo = $Formats{$format} or return undef;
    my $formatter = $fmtinfo->[0];

    state $cleanser;
    if ($Enable_Cleansing && !$fmtinfo->[2]{circular}) {
        # currently we only have one type of cleansing, oriented towards JSON
        if (!$cleanser) {
            require Data::Clean::JSON;
            $cleanser = Data::Clean::JSON->new;
        }
        $cleanser->clean_in_place($res);
    }

    my $deco = $Enable_Decoration;

    if ((reftype($formatter) // '') eq 'CODE') {
        return $formatter->($format, $res);
    } else {
        my %o;
        $o{color} = 0 if !$deco && $format =~ /json|yaml/;
        return Data::Format::Pretty::format_pretty(
            $res, {%o, module=>$formatter});
    }
}

1;
# ABSTRACT: Format envelope result


__END__
=pod

=head1 NAME

Perinci::Result::Format - Format envelope result

=head1 VERSION

version 0.31

=head1 SYNOPSIS

=head1 DESCRIPTION

This module formats enveloped result to YAML, JSON, etc. It uses
L<Data::Format::Pretty> for the backend. It is used by other Perinci modules
like L<Perinci::CmdLine> and L<Perinci::Access::HTTP::Server>.

The default supported formats are:

=over 4

=item * json

Using Data::Format::Pretty::YAML.

=item * text-simple

Using Data::Format::Pretty::SimpleText.

=item * text-pretty

Using Data::Format::Pretty::Text.

=item * text

Using Data::Format::Pretty::Console.

=item * yaml

Using Data::Format::Pretty::YAML.

=back

=for Pod::Coverage .*

=head1 VARIABLES

=head1 %Perinci::Result::Format::Formats => HASH

Contains a mapping between format names and Data::Format::Pretty::* module
names + MIME type.

=head1 $Enable_Decoration => BOOL (default: 1)

Decorations include color or other markup, which might make a data structure
like JSON or YAML string become invalid JSON/YAML. This should be turned off if
one wants to send the formatting over network.

=head1 $Enable_Cleansing => BOOL (default: 0)

If enabled, cleansing will be done to data to help make sure that data does not
contain item that cannot be handled by formatter. for example, JSON format
cannot handle circular references or complex types other than hash/array.

=head1 FUNCTIONS

None is currently exported/exportable.

=head1 format($res, $format) => STR

Format enveloped result C<$res> with format named C<$format>.

Result metadata (C<< $res->[3] >>) is also checked for key named
C<result_format_options>. The value should be a hash like this C<< { FORMAT_NAME
=> OPTS, ... } >>. This way, function results can specify the details of
formatting. An example enveloped result:

 [200, "OK", ["foo", "bar", "baz"], {
     result_format_options => {
         "text"        => {list_max_columns=>1},
         "text-pretty" => {list_max_columns=>1},
     }
 }]

The above result specifies that if it is displayed using C<text> or
C<text-pretty> format, it should be displayed in one columns instead of
multicolumns.

=head1 FAQ

=head2 How to add support for new formats?

First make sure that Data::Format::Pretty::<FORMAT> module is available for your
format. Look on CPAN. If it's not, i't also not hard to create one.

Then, add your format to %Perinci::Result::Format::Formats hash:

 use Perinci::Result::Format;

 # this means format named 'xml' will be handled by Data::Format::Pretty::XML
 $Perinci::Result::Format::Formats{xml} = ['XML', 'text/xml'];

=head1 SEE ALSO

L<Data::Format::Pretty>

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

