package Row::TestOptional;

use Parse::FixedRecord;

extends 'Parse::FixedRecord::Row';

column code              => width => 12, isa => 'Int';
column description       => width => 50, isa => 'Str';
column year_discontinued => width => 4, isa => 'Int', optional => 1;

