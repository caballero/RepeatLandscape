#!/usr/bin/perl

=head1 NAME

RepeatLandscape.pl

=head1 DESCRIPTION

create the repeat landscape from scratch

=head1 USAGE

RepeatLandscape.pl [PARAM]
   
    PARAMETER      DESCRIPTION
    -a --align     cross_match aligment [REQUIRED, SPECIE.fa.align.gz]
    -g --genome    Genome in Fasta [Required only if the genome size will be computed]
    -s --specie    Short name for the files/specie [Deault: SPECIE]
    -n --name      Common name of the specie (undescores are changed to spaces)
    --html         Create complete HTML page [Default is just the javascript]
    -h --help      Print this screen
    -v --verbose   Verbose mode ON

=head1 EXAMPLES

    RepeatLandscape.pl -a mysp.fa.align.gz

    RepeatLandscape.pl -a mysp.align -s mysp -n My_name

    RepeatLandscape.pl -a mysp.fa.align.gz -g mysp.fasta.gz


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
use Getopt::Long;
use Pod::Usage;

# Default parameters
my $help     = undef;         # Print help
my $verbose  = undef;         # Verbose mode
my $align    = undef;
my $name     = undef;
my $sp       = undef;
my $genome   = undef;
my $html     = undef;
my $opt      =    '';

# Calling options
GetOptions(
    'h|help'           => \$help,
    'v|verbose'        => \$verbose,
    'a|align=s'        => \$align,
    'g|genome:s'       => \$genome,
    'n|name:s'         => \$name,
    'html'             => \$html,
    's|sp:s'           => \$sp
) or pod2usage(-verbose => 2);
pod2usage(-verbose => 2)     if (defined $help);
pod2usage(-verbose => 2) unless (defined $align);

# get the species name
unless (defined $sp) {
    $sp = $align;
    $sp =~ s/\.fa.align.gz//;
}

# get the common name
unless (defined $name) {
    $name = $sp;
}

if (defined $genome) {
    warn "obtaining genome size from $genome\n" if (defined $verbose);
    system ("perl calcGenomeSize.pl $genome >> genome.size");
}

warn "processing alignment file $align\n" if (defined $verbose);
system ("perl KimuraDist_noCG_fromRMalign.pl -nolow $align > $sp.kout");

warn "processing kimura file $sp.kout\n" if (defined $verbose);
$opt = '-v' if (defined $verbose);
system ("perl parseKimuraOut.pl -k $sp.kout $opt");

warn "creating google chart using $sp.csv\n" if (defined $verbose);
if (defined $html) {
    system ("perl createGoogleVizHist.pl -c $sp.csv -t $name -o $sp.html");
}
else {
    system ("perl createGoogleVizHistJS.pl -c $sp.csv -t $name -o $sp.js");
}
