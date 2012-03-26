#!/usr/bin/perl -w

my ($script) = ($0 =~ m|([^/]*)$|);
$USAGE = "usage: $script [-rep repeatname] (-indels) <cross_match output WITH ALIGNMENTS>

-indels  gaps are counted as a single substitution and are treated as transversions in Kimura calc
         by default the mismatch and substitution level of matched bases only is calculated
-rep for which repeat to calculate substitution level; end name with __ if an exact match is required
-nolow skip low complexity and simple repeats \n";

die $USAGE unless $ARGV[0];

# includes
#use POSIX;  with this you can use "floor" instead if "int"
use Getopt::Long;
@opts = qw(indels rep:s nolow);
$opt_indels = $opt_rep = $opt_nolow = "";
unless (GetOptions(@opts)) {
    printf STDERR $USAGE;
    exit (1);
}
if ($opt_rep =~ /__$/) {
    $opt_rep =~ s/__$//;
    $exact = 1;
}
$repeat = quotemeta $opt_rep;	# otherwise goes wrong with () in name

my $queryname = "";
foreach $file (@ARGV) {
  my $fileh = $file;
  $fileh = "gunzip  -c $file | " if ($file =~ m/gz$/);
  $fileh = "bunzip2 -c $file | " if ($file =~ m/bz2$/);
  open (FILE, $fileh) or die "cannot open $file\n";
  print "file: $file\n";
  my $class = "";
  my $count = 0;
  my $count2 = 0;
  my $hitname = "";
  my $lastinfo = "";
  my $lastmut = "";
  my $lastnuc = "";
  my $length = 0;
  my $margin = 0;
  my $queryname = "";
  my $querynumber = 0;
  my $transitions = 0;
  my $transversions = 0;
  my %class = ();
  my %cnt = ();
  my %counted = ();
  my %do;
  my %indels = ();
  my %len = ();
  my %length = ();
  my %transitions = ();
  my %transversions = ();
  my @info;
  while (<FILE>) {
    if (/\(\d+\)/) {
      $lastnuc = "";
      if ($count && $length) {
	if ($opt_indels) {
	  # gaps treated like transversions in kimura. Unorthodox
	  $transversions += $indels;
	  $length += $indels;
	}
	my $p = $transitions/$length;
	my $q = $transversions/$length;
	if ( (1-2*$p-$q) < 0.0001 || (1-2*$q) < 0.0001) {
	  $kimura = 50;
	} else {
	  $kimura = -50*log((1-2*$p-$q)*(1-2*$q)**0.5);
	  # kimura is expressed in % here
	  $kimura = int $kimura;
	  $kimura = 50 if $kimura > 50;
	}
	my $cat = "$class $kimura";
	++$cnt{$cat};
	$len{$cat} += $length;
	++$do{$class};

	$length{$hitname} += $length;
	$transitions{$hitname} += $transitions;
	$transversions{$hitname} += $transversions;
	$class{$hitname} = $class;
	# reset
	$lastinfo = "";
	$transitions = $transversions = $indels = $length = $count = 0;
      }
      next if $opt_nolow && /Simple_repeat/;
      # low complexity never get a length since all matches/mismatches are "?"
      next if /Low_complexity/;
      my @bit = split;
      #for now
      #next if $bit[10] =~ /RNA/;
      $queryname =  $bit[4];
# to work only on RepeatMasker .align files, which have a + added.
      if ($bit[8] eq "C" || $bit[8] eq '+') {
	$hitname = $bit[9];
	$class = $bit[10];
      } else {
	$hitname = $bit[8];
	$class = ($hitname =~ s/\#.+//);
      }

# The RepeatMasker .align files do not ahve an ID yet, so the number
# of copies for each element can not be calculated from it. Pity.
      $queryname =~ s/([\S]{12}).*/$1/; # truncate to 13 as is done in alignment                               
      # when > 1000000 name is truncated to 12 letters                                                         
      $queryname = quotemeta $queryname;
      
      # limiting to requested repeat & counting number of query sequences with a match
      if (!$repeat) {
	$count = 1;
	unless ( $counted{$queryname} ) {
	  ++$querynumber;
	  $counted{$queryname} = 1;
	}
      }
      elsif ($queryname =~ /$repeat/i || $hitname =~ /$repeat/i) {
	if ($exact) {
	  $hitname =~ s/\#.*$//;
	  $hitname =~ s/_[35]end$//;
	  if ($hitname eq "$repeat") {
	    $count = 1;
	    unless ( $counted{$queryname} ) {
	      ++$querynumber;
	      $counted{$queryname} = 1;
	    }
	  }
	} else {
	  $count = 1;
	  unless ( $counted{$queryname} ) {
	    ++$querynumber;
	    $counted{$queryname} = 1;
	  }
	}
      }
    }
    elsif ($count && /^\s*$queryname/) {
      /^(C?\s+\S+\s+\d+\s+)(\S+)/;
      $margin = length $1;
      $length += length $2;
      $count2 = "differences";
    }
    # line with indication of mismatches ( i v ? and - )
    elsif ($count2 eq "differences") {
      chomp;
      # just to be sure the array has 50 scalars:
      $_ .= '                                                  ';
      my $info = substr($_,$margin,50);
      $_ =~ s/\s+$/\n/;
      @info = split "", $info;
      $transitions += (s/i/i/g);
      $transversions += (s/v/v/g);
      # count the number of indels inits
      $indels += (s/([iv\? ]-)/$1/g);
#indel initiations counted as one substitution
#            $indels += s/g/g/g;

      # ambiguous matches subtracted from length as they are not
      # included in subst.level
      $length -= (s/\?/\?/g); 
      # delete indel extensions from total length
      # indels continuing on next line are counted as two (imperfection)
      $length -= (s/-/-/g);
      $count2 = "consensus";
    } elsif ($count2 eq "consensus") {
      /\S+\s+-?\d+\s(\S+)\s-?\d+/;
      print "$_" unless $1;
      my $base = $1;
      my @base = split "", $base;
      for (my $i = 0; $i <= $#base; ++$i) {
	if ($lastnuc eq 'C' && $base[$i] eq 'G') {
	  --$transitions if $info[$i] eq 'i';
	  --$transversions if $info[$i] eq 'v';
	  if ($i > 0) {
	    --$transitions if $info[$i-1] eq 'i';
	    --$transversions if $info[$i-1] eq 'v';
	  } else {
	    --$transitions if $lastmut eq 'i';
	    --$transversions if $lastmut eq 'v';
	  }
	  $length -= 2;
	  ++$length if $info[$i] eq '-';
	  ++$length if $info[$i-1] eq '-';
	}
	$lastnuc = $base[$i];
      }
      $lastnuc = $base[$#base];
      $lastmut = $info[$#base];
      $count2 = "";
    }
    $lastinfo .= $_ if $count;
  }
  if ($count && $length) {
    if ($opt_indels) {
      # gaps treated like transversions in kimura. Unorthodox
      $transversions += $indels;
      $length += $indels;
    }
    my $p = $transitions/$length;
    my $q = $transversions/$length;
    my $kimura;
    if ( (1-2*$p-$q) < 0.0001 || (1-2*$q) < 0.0001) {
      $kimura = 50;
    } else {
      $kimura = -50*log((1-2*$p-$q)*(1-2*$q)**0.5);
      # kimura is expressed in % here;
      $kimura = int $kimura;
      $kimura =50 if $kimura > 50;
    }
    my $cat = "$class $kimura";
    ++$cnt{$cat};
    $len{$cat} += $length;
    ++$do{$class};
    
    $length{$hitname} += $length;
    $transitions{$hitname} += $transitions;
    $transversions{$hitname} += $transversions;
    $class{$hitname} = $class;
    # reset
    $transitions = $transversions = $indels = $length = $count = 0;
  }
  my $cl ="";
  my $type = "";
  print "Jukes/Cantor and Kimura subsitution levels excluding mutations in CpGs in the consensus\n
class\trepeat\tjukes\tkimura\n";
  foreach $cl (sort keys %do) {
    foreach $type (sort keys %class) {
      next unless $class{$type} eq $cl;
      my $subs = ($transitions{$type} + $transversions{$type})/$length{$type};
      my $avejuke;
      if (1.33333333*$subs >= 1) {
	$avejuke = 50;
      } else {
	$avejuke = -75*log(1-1.33333333*$subs);
	$avejuke = sprintf "%4.2f", $avejuke;
      }
      my $p = $transitions{$type} / $length{$type};
      my $q = $transversions{$type} / $length{$type};
      my $avekim;
      if ( (1-2*$p-$q) < 0.0001 || (1-2*$q) < 0.0001) {
	$avekim = 50;
      } else {
	$avekim = -50*log((1-2*$p-$q)*(1-2*$q)**0.5);
	$avekim = sprintf "%4.2f", $avekim;
      }
      print "$cl\t$type\t$avejuke\t$avekim\n"
      #this "otherkim" gives the same result; don't know why I have both in CntSubst
#      my $otherkim = 0.5*log(1/(1-2*$p-$q)) + 0.25*log(1/(1-2*$q));
#      $otherkim = sprintf "%5.3f", $otherkim;
#      print "$cl\t$type\t$avejuke\t$avekim\t$otherkim\n";
    }
  }
  
  print "\n\n0kimura ";
  foreach $cl (sort keys %do) {
    print "$cl ";
  }
  
  print "\n";
  my $j = 0;
  while ($j <= 50) {
    print "$j ";
    foreach $cl (sort keys %do) {
      $label = "$cl $j";
      # counting is pretty useless without linked fragments
#    $cnt{$cat} = 0 unless $cnt{$cat};
      $len{$label} = 0 unless $len{$label};
#    print "$cnt{$cat} $len{$cat} ";
      print "$len{$label} ";
    }
    print "\n";
    ++$j;
  }
}



