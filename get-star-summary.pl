#!/usr/bin/perl
#
# Merge the mapping summary from the Log.final.out generated from STAR
#
# Usage
#       perl get-star-summary.pl allIDs.txt <summary file>[optional, default to star-mapping-summary.txt]
#
# Shanrong Zhao
#

use strict;

if (@ARGV < 1) {
        print "Usage: $0 <id file> <summary file>[optional, default to star-mapping-summary.txt]\n";
        exit;
}

my $Summary_File="star-mapping-summary.txt";
if (@ARGV > 1) {
        $Summary_File=$ARGV[1];
}

sub getSummary {
        my $id = shift;
        open (SUMMARY, "<${id}_Log.final.out") || die $@;

        my ($total_reads, $uniq_reads, $read_length, $map_length, $multi_rate, $uniq_rate, $unmap_rate);

        while (my $aline = <SUMMARY>) {
        #       next unless $aline =~ /reads/;
                chomp($aline);

                $aline =~ s/^\s+|\s+$//g;
                my @aitems = split(/\|/, $aline);

                my $key = $aitems[0];
                $key =~ s/\s+$//g;
                my $val= $aitems[1];
                $val =~ s/\s+//g;

                $total_reads=$val if ($key eq "Number of input reads");
                $uniq_reads=$val if ($key eq "Uniquely mapped reads number");
                $read_length=$val if ($key eq "Average input read length");
                $map_length=$val if ($key eq "Average mapped length");
                $uniq_rate=$val if ($key eq "Uniquely mapped reads %");
                $multi_rate=$val if ($key eq "% of reads mapped to multiple loci");
        }

        close(SUMMARY);

        $uniq_rate =~ s|(\d+\.\d+)%|$1|eg;
        $multi_rate =~ s|(\d+\.\d+)%|$1|eg;
        $unmap_rate = 100 - $uniq_rate - $multi_rate;
        $unmap_rate = sprintf("%5.2f", $unmap_rate);
        return "$id\t$total_reads\t$uniq_rate\t$multi_rate\t$unmap_rate";
}


open (OUTPUT, ">$Summary_File") || die $@;
print OUTPUT "Sample\tTotal_reads\tUniq_Rate\tMulti_Rate\tUnmap_Rate\n";

open(FILE, $ARGV[0]) || die $@;
while(my $line = <FILE>) {
        chomp($line);
        my @items = split(/\t/, $line);
        my $id = $items[0];

        print OUTPUT getSummary($id), "\n";
}

close(FILE);
close(OUTPUT);

