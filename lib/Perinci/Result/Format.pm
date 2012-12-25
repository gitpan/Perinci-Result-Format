package Perinci::Result::Format;

use 5.010;
use strict;
use warnings;

use Scalar::Util qw(reftype);

our $VERSION = '0.29'; # VERSION

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
        $opts = $res->[3]{result_format_options} // {};
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
    yaml          => ['YAML', 'text/yaml'],
    json          => ['CompactJSON', 'application/json'],
    'json-pretty' => ['JSON', 'application/json'],
    text          => [$format_text, 'text/plain'],
    'text-simple' => [$format_text, 'text/plain'],
    'text-pretty' => [$format_text, 'text/plain'],
);

sub format {
    require Data::Format::Pretty;

    my ($res, $format) = @_;

    my $formatter = $Formats{$format} or return undef;

    if ((reftype($formatter->[0]) // '') eq 'CODE') {
        return $formatter->[0]->($format, $res);
    } else {
        return Data::Format::Pretty::format_pretty(
            $res, {module=>$formatter->[0]});
    }
}

1;
# ABSTRACT: Format envelope result


__END__
=pod

=head1 NAME

Perinci::Result::Format - Format envelope result

=head1 VERSION

version 0.29

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

=head1 %Perinci::Result::Format::Formats

Contains a mapping between format names and Data::Format::Pretty::* module
names + MIME type.

=head1 FUNCTIONS

None is currently exported/exportable.

=head1 format($res, $format) => STR

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

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

