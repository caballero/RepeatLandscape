#!/usr/bin/perl

=head1 NAME

plotHist.pl

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

$ARGV[0] or die "use plotHist.pl DATA.csv\n";

my $file = shift @ARGV;
my $name = $file; $name =~ s/.csv//;

open  F, ">$name.R" or die "cannot open file $name.R\n";
print F <<_HERE_
# reading file
data     = read.table("$file", header=T, row.names=1)

# color palettes definitions
#colf     = read.table("repeats.palette", header=T)
dna.pal  = colorRampPalette(c("red",       "lightsalmon"), space ="Lab")
line.pal = colorRampPalette(c("darkblue",    "lightblue"), space ="Lab")
ltr.pal  = colorRampPalette(c("darkgreen",  "lightgreen"), space ="Lab")
sine.pal = colorRampPalette(c("purple",       "lavender"), space ="Lab")
#sat.pal  = colorRampPalette(c("goldenrod3",       "gold"), space ="Lab")

# color order is important:
# DNA/Academ DNA/CMC DNA/Crypton DNA/Ginger DNA/Harbinger DNA/hAT DNA/Kolobok DNA/Maverick DNA DNA/Merlin DNA/MULE DNA/P DNA/PiggyBac DNA/Sola DNA/TcMar DNA/Transib DNA/Zator RC/Heltrion LTR/DIRS LTR/Ngaro LTR/Pao LTR/Copia LTR/Gypsy LTR/ERVL LTR LTR/ERV1 LTR/ERV LTR/ERVK LINE LINE/L1 LINE/L2 LINE/CR1 LINE/Rex-Babar LINE/RTE LINE/Dong-R4 LINE/Jockey-I LINE/LOA LINE/Penelope LINE/Proto2 LINE/R1 LINE/R2 LINE/Jockey Other Other/composite SINE SINE/5S SINE/7SL SINE/Alu SINE/B2 SINE/B4 SINE/BovA SINE/C SINE/CORE SINE/Deu SINE/ID SINE/Lys SINE/Mermaid SINE/RTE SINE/Sauria SINE/V SINE/tRNA Unknown Unknown/Y-chromosome
colors   = c(dna.pal(17), "magenta", ltr.pal(10), line.pal(13), "gray30", "gray50", sine.pal(15), "grey60", "grey80") 
#colors   = colf\$COLOR

# output file
png("$name.png", height = 900, width = 600)

# plot!
barplot(t(as.matrix(data)), border = NA, col = colors, main = "$name", ylab = "\% genome", xlab = "\% div", ylim = c(0,2.8))

# legend
#legend("topright", names(data), fill = colors, ncol = 8, cex = 0.8)

_HERE_
;

close F;

system ("R --vanilla -q < $name.R > $name.Rout");

