#!/usr/bin/perl

use strict; use warnings;
use Test::More tests => 1;
use FindBin '$Bin';

use lib "$Bin/lib";
use Row::TestOptional;

# example of parsing a whole table

my @rows = map {
              Row::TestOptional->parse($_) 
           }
           <DATA>;
my @discontinued = grep { $_->year_discontinued } @rows;

is_deeply [ map $_->year_discontinued, @discontinued ],
          [ 1995, 2000 ],
          "Correct data";

__DATA__
000000000001A fine product                                    1995
000000000002Another fine product                              
000000000003Another fine product                              2000
