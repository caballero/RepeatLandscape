#!/usr/bin/perl

use strict;
use warnings;

my %size;
my %data;
my %rep;
my %div;
my %sum;

warn "reading genome sizes\n";
open G, "genome.size" or die;
while (<G>) {
    chomp;
    my @a = split (/\t/, $_);
    $size{$a[0]} = $a[2];
}
close G;

warn "parsing files\n";
opendir D, "." or die;
while (my $file = readdir D) { 
    next unless ($file =~ m/kout$/);
    warn "    reading $file\n";
    my $sp  = $file; $sp =~ s/.kout//;
    die "cannot get size of $sp\n" unless (defined $size{$sp});
    my $gs  = $size{$sp};
    my $rec = 0;
    my @rep = ();
    open F, "$file" or die;
    while (<F>) {
        chomp;
        my @a = split (/\s+/, $_);
        if (m/^0kimura/) {
            shift @a;
            foreach my $r (@a) {
                $r =~ s/\?//g;
                # Specific class changes requested by Arian
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
                # Skip this repeats
                #next if ($r =~ m#ARTEFACT|centromeric|Satellite|Segmental|rRNA|scRNA|snRNA|tRNA# and $r !~ m#SINE#);               
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
}

my @sp  = sort keys %data;
# order is IMPORTANT for plotting
my @rep = qw(Unknown DNA/Academ DNA/CMC DNA/Crypton DNA/Ginger DNA/Harbinger DNA/hAT DNA/Kolobok DNA/Maverick DNA DNA/Merlin DNA/MULE DNA/P DNA/PiggyBac DNA/Sola DNA/TcMar DNA/Transib DNA/Zator RC/Heltrion LTR/DIRS LTR/Ngaro LTR/Pao LTR/Copia LTR/Gypsy LTR/ERVL LTR LTR/ERV1 LTR/ERV LTR/ERVK LINE/L1 LINE LINE/RTE LINE/CR1 LINE/Rex-Babar LINE/L2 LINE/Proto2 LINE/LOA LINE/R1 LINE/Jockey-I LINE/Dong-R4 LINE/R2 LINE/Penelope Other Other/composite SINE SINE/5S SINE/7SL SINE/Alu SINE/tRNA SINE/tRNA-Alu SINE/tRNA-RTE SINE/RTE SINE/Deu SINE/tRNA-V SINE/MIR SINE/Sauria SINE/tRNA-7SL SINE/tRNA-CR1);
my @div = sort {$a<=>$b} keys %div;

foreach my $sp (@sp) {
    warn "writing $sp.csv\n";
    my @sprep = @rep;
    open  O, ">$sp.csv22" or die;
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
}
