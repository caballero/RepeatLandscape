#!/usr/bin/perl

use strict;
use warnings;

#print "#Species\tTotal_Genome\tNo_N100+\tNo_Ns\n";

opendir D, '.' or die "cannot read local dir\n";
while (my $file = readdir D) {
    next unless ($file =~ m/fa$/);
    my %seq  = ();
    my $id   = '';
    open F, "$file" or die "cannot read $file\n";
    while (<F>) {
        chomp;
        if (m/>/) {
           $id = $_;
           next;
        }
        $seq{$id} .= $_;
    }
    close F;
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
    $file =~ s/.fa$//;
    print "$file\t$len1\t$len2\t$len3\n";
}
