#!/usr/bin/perl

=head1 NAME

parseKimuraOut.pl

=head1 DESCRIPTION

parse the ouput of KimuraDist_noCG_fromRMalign.pl, repeats are sorted and 
renamed, total bases are converted to percetages.

=head1 USAGE

perl parseKimuraOut.pl [PARAM]
   
    PARAMETER        DESCRIPTION
    -k --kout        Kimura file         [FILE.kout]
    -g --genomesize  Genome sizes file   [Default: genome.size]
    -o --out         Write table here    [Default: FILE.csv]
    -v --verbose     Verbose mode ON
    -h --help        Print this screen

=head1 EXAMPLES

    perl parseKimuraOut.pl -k FILE.kout
    
    perl parseKimuraOut.pl -k FILE.kout -g mygenome_sizes.txt
    
    perl parseKimuraOut.pl -k FILE.kout -o myoutput.txt
    

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
my $kout    = undef;
my $gsize   = 'genome.size';
my $out     = undef;
my $help    = undef;
my $verbose = undef;

# Main variables
my %size;
my %data;
my %rep;
my %div;
my %sum;
# order is IMPORTANT for plotting
my @rep_order = qw( 
              Unknown 
              DNA/Academ 
              DNA/CMC 
              DNA/Crypton 
              DNA/Ginger 
              DNA/Harbinger 
              DNA/hAT 
              DNA/Kolobok 
              DNA/Maverick 
              DNA 
              DNA/Merlin 
              DNA/MULE 
              DNA/P 
              DNA/PiggyBac 
              DNA/Sola 
              DNA/TcMar 
              DNA/Transib 
              DNA/Zator 
              RC/Heltrion 
              LTR/DIRS 
              LTR/Ngaro 
              LTR/Pao 
              LTR/Copia 
              LTR/Gypsy 
              LTR/ERVL 
              LTR 
              LTR/ERV1 
              LTR/ERV 
              LTR/ERVK 
              LINE/L1 
              LINE 
              LINE/RTE 
              LINE/CR1 
              LINE/Rex-Babar 
              LINE/L2 
              LINE/Proto2 
              LINE/LOA 
              LINE/R1 
              LINE/Jockey-I 
              LINE/Dong-R4 
              LINE/R2 
              LINE/Penelope 
              Other 
              Other/composite 
              SINE 
              SINE/5S 
              SINE/7SL 
              SINE/Alu 
              SINE/tRNA 
              SINE/tRNA-Alu 
              SINE/tRNA-RTE 
              SINE/RTE 
              SINE/Deu 
              SINE/tRNA-V 
              SINE/MIR 
              SINE/Sauria 
              SINE/tRNA-7SL 
              SINE/tRNA-CR1
            );


# Calling options
GetOptions (
    'k|kout:s'          => \$kout,
    'g|genomesize:s'    => \$gsize,
    'o|out:s'           => \$out,
    'h|help'            => \$help,
    'v|verbose'         => \$verbose
) or pod2usage(-verbose => 2);
pod2usage(-verbose => 2)     if (defined $help);
pod2usage(-verbose => 2) unless (defined $kout);

warn "reading genome sizes from $gsize\n" if (defined $verbose);
open G, "$gsize" or die "cannot read $gsize\n";
while (<G>) {
    next if (m/^#/);
    chomp;
    my @a = split (/\t/, $_);
    $size{$a[0]} = $a[2];
}
close G;

warn "parsing file $kout\n" if (defined $verbose);
my $sp  = $kout; 
$sp =~ s/.kout//;
die "cannot get genome size for $sp\n" unless (defined $size{$sp});
my $gs  = $size{$sp};
my $rec = 0;
my @rep = ();
open F, "$kout" or die "cannot read $kout\n";
while (<F>) {
    chomp;
    my @a = split (/\s+/, $_);
    if (m/^0kimura/) {
        shift @a;
        foreach my $r (@a) {
            $r =~ s/\?//g;
            # Specific name changes requested by Arian
            $r =~ s#DNA/Chompy#DNA#;
            $r =~ s#DNA/CMC-Chapaev#DNA/CMC#;
            $r =~ s#DNA/CMC-Chapaev-3#DNA/CMC#;
            $r =~ s#DNA/CMC-EnSpm#DNA/CMC#;
            $r =~ s#DNA/CMC-Transib#DNA/CMC#;
            $r =~ s#DNA/En-Spm#DNA/CMC#;
            $r =~ s#DNA/PIF-Harbinger#DNA/Harbinger#;
            $r =~ s#DNA/PIF-ISL2EU#DNA/Harbinger#;
            $r =~ s#DNA/Tourist#DNA/Harbinger#;
            $r =~ s#DNA/AcHobo#DNA/hAT#;
            $r =~ s#DNA/Charlie#DNA/hAT#;
            $r =~ s#DNA/Chompy1#DNA/hAT#;
            $r =~ s#DNA/MER1_type#DNA/hAT#;
            $r =~ s#DNA/Tip100#DNA/hAT#;
            $r =~ s#DNA/hAT-Ac#DNA/hAT#;
            $r =~ s#DNA/hAT-Blackjack#DNA/hAT#;
            $r =~ s#DNA/hAT-Charlie#DNA/hAT#;
            $r =~ s#DNA/hAT-Tag1#DNA/hAT#;
            $r =~ s#DNA/hAT-Tip100#DNA/hAT#;
            $r =~ s#DNA/hAT-hATw#DNA/hAT#;
            $r =~ s#DNA/hAT-hobo#DNA/hAT#;
            $r =~ s#DNA/hAT_Tol2#DNA/hAT#;
            $r =~ s#DNA/Kolobok-IS4EU#DNA/Kolobok#;
            $r =~ s#DNA/Kolobok-T2#DNA/Kolobok#;
            $r =~ s#DNA/T2#DNA/Kolobok#;
            $r =~ s#DNA/MULE-MuDR#DNA/MULE#;
            $r =~ s#DNA/MULE-NOF#DNA/MULE#;
            $r =~ s#DNA/MuDR#DNA/MULE#;
            $r =~ s#DNA/piggyBac#DNA/PiggyBac#;
            $r =~ s#DNA/MER2_type#DNA/TcMar#;
            $r =~ s#DNA/Mariner#DNA/TcMar#;
            $r =~ s#DNA/Pogo#DNA/TcMar#;
            $r =~ s#DNA/Stowaway#DNA/TcMar#;
            $r =~ s#DNA/Tc1#DNA/TcMar#;
            $r =~ s#DNA/Tc2#DNA/TcMar#;
            $r =~ s#DNA/Tc4#DNA/TcMar#;
            $r =~ s#DNA/TcMar-Fot1#DNA/TcMar#;
            $r =~ s#DNA/TcMar-ISRm11#DNA/TcMar#;
            $r =~ s#DNA/TcMar-Mariner#DNA/TcMar#;
            $r =~ s#DNA/TcMar-Pogo#DNA/TcMar#;
            $r =~ s#DNA/TcMar-Tc1#DNA/TcMar#;
            $r =~ s#DNA/TcMar-Tc2#DNA/TcMar#;
            $r =~ s#DNA/TcMar-Tigger#DNA/TcMar#;
            $r =~ s#DNA/Tigger#DNA/TcMar#;
            $r =~ s#DNA/Helitron#RC/Helitron#;
            $r =~ s#LTR/DIRS1#LTR/DIRS#;
            $r =~ s#LTR/ERV-Foamy#LTR/ERVL#;
            $r =~ s#LTR/ERV-Lenti#LTR/ERV#;
            $r =~ s#LTR/ERVL-MaLR#LTR/ERVL#;
            $r =~ s#LTR/Gypsy-Troyka#LTR/Gypsy#;
            $r =~ s#LTR/MaLR#LTR/ERVL#;
            $r =~ s#LINE/CR1-Zenon#LINE/CR1#;
            $r =~ s#LINE/I#LINE/Jockey-I#;
            $r =~ s#LINE/Jockey#LINE/Jockey-I#;
            $r =~ s#LINE/L1-Tx1#LINE/L1#;
            $r =~ s#LINE/R2-Hero#LINE/R2#;
            $r =~ s#LINE/RTE-BovB#LINE/RTE#;
            $r =~ s#LINE/RTE-RTE#LINE/RTE#;
            $r =~ s#LINE/RTE-X#LINE/RTE#;
            $r =~ s#LINE/telomeric#LINE/Jockey-I#;
            $r =~ s#SINE/B2#SINE/tRNA#;
            $r =~ s#SINE/B4#SINE/tRNA-Alu#;
            $r =~ s#SINE/BovA#SINE/tRNA-RTE#;
            $r =~ s#SINE/C#SINE/tRNA#;
            $r =~ s#SINE/CORE#SINE/RTE#;
            $r =~ s#SINE/ID#SINE/tRNA#;
            $r =~ s#SINE/Lys#SINE/tRNA#;
            $r =~ s#SINE/MERMAID#SINE/tRNA-V#;
            $r =~ s#SINE/RTE-BovB#SINE/RTE#;
            $r =~ s#SINE/tRNA-Glu#SINE/tRNA#;
            $r =~ s#SINE/tRNA-Lys#SINE/tRNA#;
            $r =~ s#SINE/V#SINE/tRNA-V#;
            $r =~ s#Unknown/Y-chromosome#Unknown#;
            $rep{$r} = 1;
            push @rep, $r;
        }
        $rec = 1;
    }
    elsif ($rec == 1) {
        my $div = shift @a;
        $div{$div} = 1;
        for (my $i = 0; $i <= $#a; $i++) {
            my $per = 100 * $a[$i] / $gs;
            my $rep = $rep[$i];
            $data{$sp}{$rep}{$div} += $per;
            $sum{$sp}{$rep} += $per;
        }
    }
} 
close G;

# define the output file
unless (defined $out) {
    $out = "$sp.csv";
}

warn "writing final table in $out\n" if (defined $verbose);
my @sprep = ();
my @div = sort {$a<=>$b} keys %div;
foreach my $rep (@rep_order) {
    if (defined $sum{$sp}{$rep}) {
        push @sprep, $rep if ($sum{$sp}{$rep} > 0);
    }
}
open  O, ">$out" or die "cannot write $out\n";
print O join "\t", 'DIV', @sprep;
print O "\n";
foreach my $div (@div) {
     print O "$div";
     foreach my $rep (@sprep) {
         my $per = 0;
         $per = $data{$sp}{$rep}{$div} if (defined $data{$sp}{$rep}{$div});
         print O "\t$per";
     }
     print O "\n";
}
close O;
