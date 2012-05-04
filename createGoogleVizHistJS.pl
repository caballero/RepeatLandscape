#!/usr/bin/perl

=head1 NAME

createGoogleVizHist.pl

=head1 DESCRIPTION

create the basic JS to plot an stocked histogram.

=head1 USAGE

   perl createGoogleVizHist.pl -c CSV -o HTML

   Parameters        Description            Value         Default
   -c --csv          CSV with values        File          STDIN
   -o --out          HTML output            File          STDOUT
   -p --palette      Color palette          File          repeats.palette
   -t --title        Plot title             Str           Repeat Landscape 
   
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
my $title    = 'Repeat Landscape';
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

$tittle =~ s/_/ /g;

openFH();

while (<>) {
    chomp;
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
