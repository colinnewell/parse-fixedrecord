package Parse::FixedRecord;

=head1 NAME

Parse::FixedRecord - object oriented parser for fixed width records

=head1 SYNOPSIS

Assuming you have data like this:

  Fred Bloggs | 2009-12-08 | 01:05
  Mary Blige  | 2009-12-08 | 00:30

To create a parser:

  package My::Parser;
  use Parse::FixedRecord; # imports strict and warnings
  extends 'Parse::FixedRecord::Row';

  column first_name => width => 4, isa => 'Str';
  pic ' ';
  column last_name  => width => 6, isa => 'Str';
  pic ' | ';
  column date       => width => 10, isa => 'Date';
  pic ' | ';
  column duration   => width => 5, isa => 'Duration';
  1;

In your code:

  use My::Parser;
  while (my $line = <$fh>) {
    eval {
      my $object = My::Parser->parse( $line );
      say $object->first_name;
      do_something() if $ $object->duration->in_units('mins') > 60;
    };
  }

=head1 DESCRIPTION

C<Parse::FixedRecord> is a subclass of L<Moose> with a simple domain specific
language (DSL) to define parsers.

You may use any type constraints you like, as long as they have a coercion
from Str.  If you wish to output row objects in the same format, they should
also have an overload.

C<Parse::FixedRecord> provides C<Duration> and C<DateTime> constraints for
you out of the box.

=head2 Definition

To define the class, simply apply C<column> and C<pic> for each field, in
the order they appear in your input file.  They are defined as follows:

=head3 C<column>

This is a specialisation of C<Moose>'s C<has>, which applies the
L<Parse::FixedRecord::Column> trait.

You must supply a 'width' parameter.
Unless you specify otherwise, the trait will default to C<is =E<gt> 'ro'>,
so will be readonly.

  column foo => width => 10;                     # readonly accessor
  column bar => width => 5, is => 'rw';          # read/write
  column baz => width => 5, isa => 'Some::Type';

=head3 C<pic>

You may also supply delimiters.  As this is a fixed record parser, allowing
delimiters may seem odd.  But it may be convenient for some (odd) datasets,
and in any case, there is no requirement to use it.

  column foo => width => 5;
  pic ' | ';
  column bar => width => 5;

i.e. the record consists of two 5-char wide fields, split by the literal 
C<' | '>.

=head3 C<optional>

It is possible to declare columns as optional.

  column style_code   => width => 12, isa => 'Int', optional => 1;

If an optional column is encountered and it doesn't contain any non whitespace 
data it will not be filled in on the object.  These mostly make sense in terms
of adding optional fields that can appear at the end of the record.  Especially
if you want to do a round trip with the records.  The Row output function will
only work in a sane fashion with optional fields that appear at the end.

=head2 Parsing

=head3 C<$parser-E<gt>parse>

  my $obj = My::Parser->parse( $line );

If the C<column> and C<pic> definitions can be matched, including any
type constraints and object inflations, then a Moose object is returned.

Otherwise, an error is thrown, usually by the Moose type constraint failure.

=head3 C<$parser-E<gt>parse_raw>

  my $obj = My::Parser->parse_raw( $line );

This simply parses the line and returns a hash, it does not perform
and type conversions or type validation.  For when you have a lot
of data and not a lot of time.  Try parse first.

=cut

use Moose ();
use Parse::FixedRecord::Column;
use Moose::Exporter;
use Moose::Util::TypeConstraints;

our $VERSION = 0.03;

Moose::Exporter->setup_import_methods(
   with_caller => ['column', 'pic'],
   also        => ['Moose' ],
);

sub pic {
    my $caller = shift;
    my $pic = shift;

    $caller->add_field($pic);
}

sub column {
    my $caller = shift;
    my ($name, %pars) = @_;
    $pars{isa} ||= 'Str';
    $pars{coerce}++ if do {
        my $t = find_type_constraint($pars{isa});
        $t && $t->has_coercion;
        };
    my $attr = $caller->meta->add_attribute(
        $name => (
            traits => ['Column'],
            is     => 'ro',
            %pars,
            ));
    $caller->add_field($attr);
}

=head1 AUTHOR and LICENSE

   (C)  osfameron 2009, <osfameron@cpan.org>

For support, try emailing me, or grabbing me on irc #london.pm or #moose
on irc.perl.org

This module is released under the same terms as Perl itself.

=cut

1;
