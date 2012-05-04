#!/usr/bin/perl

=head1 NAME

calcGenomeSize.pl

=head1 DESCRIPTION

count the total bases in a fasta file

=head1 USAGE

perl calcGenomeSize.pl FASTA >> genome.size
   
perl calcGenomeSize.pl FASTA.gz >> genome.size
   
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

$ARGV[0] or die "usage: perl calcGenomeSize.pl FASTA >> genome.size\n";

my $file = shift @ARGV;
my %seq  = ();
my $id   = '';

my $fh   = $file;
$fh = "gunzip  -c $file | " if ($file =~ m/gz$/);
$fh = "bunzip2 -c $file | " if ($file =~ m/bz2$/);
open FH, "$fh" or die "cannot read $file\n";
while (<FH>) {
    chomp;
    if (m/>/) {
        $id = $_;
        next;
    }
    $seq{$id} .= $_;
}
close FH;

my $len1 = 0;
my $len2 = 0;
my $len3 = 0;
foreach my $seq (values %seq) {
    $len1 +=  length $seq;
    $seq  =~  s/N{100,}//g;
    $len2 +=  length $seq;
    $seq  =~  s/N+//g;
    $len3 +=  length $seq;
}

$file =~ s/\.fa.*$//;
#print "#Species\tTotal_Genome\tNo_N100+\tNo_Ns\n";
print "$file\t$len1\t$len2\t$len3\n";
