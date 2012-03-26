#!/usr/bin/perl

=head1 NAME

plotPie.pl

=head1 AUTHOR

Juan Caballero, Institute for Systems Biology @ 2012

=head1 CONTACT

jcaballero@systemsbiology.org

=head1 LICENSE

This is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with code.  If not, see <http://www.gnu.org/licenses/>.

=cut

use strict;
use warnings;

$ARGV[0] or die "use plotPie.pl DATA.csv\n";

my $file = shift @ARGV;
my $name = $file; $name =~ s/.csv\d+//;

open  F, ">$name.R" or die "cannot open file $name.R\n";
print F <<_HERE_
# reading file
data     = read.table("$file", header=T, row.names=1)

# color palettes definitions
dna.pal  = colorRampPalette(c("red",       "lightsalmon"), space ="Lab")
line.pal = colorRampPalette(c("darkblue",    "lightblue"), space ="Lab")
ltr.pal  = colorRampPalette(c("darkgreen",  "lightgreen"), space ="Lab")
sine.pal = colorRampPalette(c("purple",       "lavender"), space ="Lab")
sat.pal  = colorRampPalette(c("goldenrod3",       "gold"), space ="Lab")

# color order is important:
colors   = c(dna.pal(17), "magenta", ltr.pal(10), line.pal(13), "gray30", "gray50", sine.pal(15), "grey60", "grey80", sat.pal(7)) 

# output file
png("$name.pie.png", height = 400, width = 400)

# plot!
pie(colSums(data), col=colors, border = NA, labels = NA, main = "$name")
# legend
#legend("topright", names(data), fill = colors, ncol = 8, cex = 0.8)

_HERE_
;

close F;

system ("R --vanilla -q < $name.R > $name.Rout");

