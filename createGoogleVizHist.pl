#!/usr/bin/perl

=head1 NAME

createGoogleVizHist.pl

=head1 DESCRIPTION

create the basic HTML to plot an stocked histogram.

=head1 USAGE

   perl createGoogleVizHist.pl -c CSV -o HTML

   Parameters        Description            Value         Default
   -c --csv          CSV with values        File          STDIN
   -o --out          HTML output            File          STDOUT
   -p --palette      Color palette          File          repeats.palette
   -t --title        Plot title             Str           Repeat Histogram 
   
   -h --help         Print this screen
   -v --verbose      Verbose mode ON

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
my $version  = undef;         # Version call flag
my $in       = undef;
my $out      = undef;
my $title    = 'Repeat Histogram';
my $palette  = 'repeats.palette';

# Main variables
my $our_version = 0.1;        # Script version number
my %data;
my @names;
my ($colors, $name, $div);


# Calling options
GetOptions(
    'h|help'           => \$help,
    'v|verbose'        => \$verbose,
    'c|csv:s'          => \$in,
    'o|out:s'          => \$out,
    't|title:s'        => \$title,
    'p|palette:s'      => \$palette
) or pod2usage(-verbose => 2);
    
pod2usage(-verbose => 2) if (defined $help);
printVersion() if (defined $version);

openFH();

while (<>) {
    chomp;
    s/Heltrion/Helitron/g;
    my @line = split (/\t/, $_);
    $div = shift @line;
    if (m/^DIV/) {
        @names  = @line;
        $colors = getColors(@names);
    }
    else {
        $data{$div} = join ", ", @line;
    }
}

print <<_HEADER_
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <title>Repeat Landscape</title>
    <script src="http://www.google-analytics.com/urchin.js" type="text/javascript"></script>
    <script type="text/javascript">uacct = "UA-2840131-2";urchinTracker();</script>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Divergence');
_HEADER_
;

foreach $name (@names) {
    print "          data.addColumn('number', '$name');\n";
}

print "          data.addRows(\[\n";
foreach $div (sort {$a<=>$b} keys %data) {
    my $data = $data{$div};
    print "          \[\'$div\', $data\],\n";
}

print <<_TAIL_
        ]);
        var options = {
          animation: {duration: 10},
          title: '$title',
          hAxis: {title: 'Kimura substitution level (excluding CpG)', showTextEvery: 5},
          vAxis: {title: 'percent of genome'},
          isStacked: 1,
          colors: [$colors]
        };
        var chart = new google.visualization.ColumnChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
      </script>
    </head>
    <body bgcolor="#ffffff" text="#000000" link="#525d76">
    <table border="0" width="100%" cellspacing="0">   
      <tbody> <tr>
        <td align="left" width=170 valign="baseline">
          <a href="http://www.systemsbiology.org/">
            <img src="images/isb_logo.gif" alt="The Institute for Systems Biology" align="left" border="0">
          </a>
        </td>
        <td align="left" valign="bottom" >
          <font size="+3">Repeat Landscape</font>
        </td>      </tr>    </tbody>
   </table>
   <hr noshade="noshade" size="1">
   <div id="chart_div" style="width: 1000px; height: 600px;"></div>
   <p>&#169; RepeatMasker.org</p>  
   </body>
</html>
_TAIL_
;

###################################
####   S U B R O U T I N E S   ####
###################################

# printVersion => return version number
sub printVersion {
    print "$0 $our_version\n";
    exit 1;
}

# openFH => no returns
sub openFH {
    # Opening files
    if (defined $in) {
        my $in_fh = $in;
        $in_fh = "gunzip  -c $in | " if ($in =~ m/gz$/i);
        $in_fh = "bunzip2 -c $in | " if ($in =~ m/bz2$/i);
        open STDIN, "$in_fh" or die "cannot open file $in\n";
        my $sp = $in; $sp =~ s/.csv//;
        $title = getName($sp);
    }

    if (defined $out) {
        open STDOUT, ">$out" or die "cannot open file $out\n";
    }
}

# getColors => return list of colors
sub getColors {
    my $pal = '';
    my %col = ();
    open PAL, "$palette" or die "cannot open file $palette\n";
    while (<PAL>) {
        chomp;
        my ($rep, $col) = split (/\t/, $_);
        $col{$rep} = $col;
    }
    
    foreach my $rep (@_) {
        if (defined $col{$rep}) { $pal .= "\"$col{$rep}\", "; }
        else                    { $pal .=    '"#FFFFFF", '; }
    }
    $pal =~ s/, $//;
    
    return $pal;
}

# getName => return the label
sub getName {
    my $sp  = shift @_;
    my $lab = 'unknown';
    if    ($sp eq 'hg19')    { $lab = 'Human (hg19)'; }
    elsif ($sp eq 'hg18')    { $lab = 'Human (hg18)'; }
    elsif ($sp eq 'mm9')     { $lab = 'Mouse (mm9)'; }
    elsif ($sp eq 'panTro2') { $lab = 'Chimp (panTro2)'; }
    elsif ($sp eq 'ponAbe2') { $lab = 'Orangutan (ponAbe2)'; }
    elsif ($sp eq 'rheMac2') { $lab = 'Rhesus (rheMac2)'; }
    elsif ($sp eq 'rn4')     { $lab = 'Rat (rn4)'; }
    elsif ($sp eq 'cavPor3') { $lab = 'Guinea Pig (cavPor3)'; }
    elsif ($sp eq 'felCat3') { $lab = 'Cat (felCat3)'; }
    elsif ($sp eq 'canFam2') { $lab = 'Dog (canFam2)'; }
    elsif ($sp eq 'bosTau4') { $lab = 'Cow (bosTau4)'; }
    elsif ($sp eq 'susScr2') { $lab = 'Pig (susScr2)'; }
    elsif ($sp eq 'loxAfr2') { $lab = 'Elephant (loxAfr2)'; }
    elsif ($sp eq 'ornAna1') { $lab = 'Platypus (ornAna1)'; }
    elsif ($sp eq 'monDom5') { $lab = 'Opossum (monDom5)'; }
    elsif ($sp eq 'oryCun2') { $lab = 'Rabitt (oryCun2)'; }
    elsif ($sp eq 'myoLuc2') { $lab = 'Bat (myoLuc2)'; }
    elsif ($sp eq 'equCab2') { $lab = 'Horse (equCab2)'; }
    elsif ($sp eq 'taeGut1') { $lab = 'Zebrafinch (taeGut1)'; }
    elsif ($sp eq 'galGal3') { $lab = 'Chicken (galGal3)'; }
    elsif ($sp eq 'fr2')     { $lab = 'Takifugu (fr2)'; }
    elsif ($sp eq 'danRer6') { $lab = 'Zebrafish (danRer6)'; }
    elsif ($sp eq 'braFlo1') { $lab = 'Lancelet (braFlo1)'; }
    elsif ($sp eq 'ci2')     { $lab = 'Ciona (ci2)'; }
    elsif ($sp eq 'xenTro2') { $lab = 'Frog (xenTro2)'; }
    elsif ($sp eq 'gasAcu1') { $lab = 'Stickleback (gasAcu1)'; }
    elsif ($sp eq 'strPur2') { $lab = 'Sea Urchin (strPur2)'; }
    elsif ($sp eq 'araTha5') { $lab = 'Arabidopsis (araTha5)'; }
    elsif ($sp eq 'orySat5') { $lab = 'Rice (orySat5)'; }
    elsif ($sp eq 'anoGam1') { $lab = 'Mosquito (anoGam1)'; }
    elsif ($sp eq 'dm3')     { $lab = 'Drosophila (dm3)'; }
    elsif ($sp eq 'allMis0') { $lab = 'Alligator (allMis0)'; }
    elsif ($sp eq 'anoCar2') { $lab = 'Lizard (anoCar2)'; }
    elsif ($sp eq 'dasNov2') { $lab = 'Armadillo (dasNov2)'; }
    elsif ($sp eq 'proCap1') { $lab = 'Hyrax (proCap1)'; }
    elsif ($sp eq 'nasVit1') { $lab = 'Wasp (nasVit1)'; }
    elsif ($sp eq 'choHof1') { $lab = 'Sloth (choHof1)'; }
    elsif ($sp eq 'calJac3') { $lab = 'Marmoset (calJac3)'; }
    elsif ($sp eq 'nomLeu1') { $lab = 'Gibbon (nomLeu1)'; }
    elsif ($sp eq 'turTru1') { $lab = 'Dolphin (turTru1)'; }
    elsif ($sp eq 'eriEur1') { $lab = 'Hedgehog (eriEur1)'; }
    else                     { $lab = $sp; }
    
    return $lab;
}

