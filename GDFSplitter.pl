#! /usr/bin/perl -w

use strict;

my $scriptName = $0;
my $time       = localtime;
print "Starting $scriptName $time \n";
# Usage help
if($#ARGV != 1) {
	print "Usage ::: $scriptName inputGDF OuputDirectory";
	exit 1;  
}

# Get command line arguments.
my $inputGDF  = $ARGV[0];
my $outputDIR = $ARGV[1];

# Open input GDF file in UTF-8 encoding
open(FH, "<:encoding(UTF-8)", $inputGDF) or die $!;

my @headerInfo;
my $gdfFileName = "";
my @gdfFileInfo;

while(<FH>) {
	
	# Check for the start of a section. 
	if($_ =~ /^1601/) {
    	
    	if($gdfFileName ne "") {
    		# Insert termination record at end of every GDF file except last one.
    		push @gdfFileInfo, "99                                                                            00";   		    		
    		writeOuputFile($gdfFileName, \@headerInfo, \@gdfFileInfo);
    	}
    	
    	undef @gdfFileInfo; # Clear array for storing next section info.
    	
    	if ($_ =~ /1601\s*(\S*)\s*/) { # Fetching the section name.
            $gdfFileName = $1;
        }
	}

   if($gdfFileName ne "") { # gdfFileName not yet set means lines contain only header info. 
       push @gdfFileInfo, $_;
   } else {
        push @headerInfo, $_;   
   }  
}

# Last section info
writeOuputFile($gdfFileName, \@headerInfo, \@gdfFileInfo);

close FH or die $!; # Close the input file.
$time = localtime;
print "$scriptName finished successfully... $time \n";

# Open output gdf files in UTF-8 encoding and dump header and section info
sub writeOuputFile
{
    my ($gdfFileName, $headerInfo, $gdfFileInfo) = @_;
    my @headerInfo  = @$headerInfo;
    my @gdfFileInfo = @$gdfFileInfo;
    
    print "Generating ${outputDIR}/${gdfFileName}.gdf ...\n";
    open(OUT, ">>:encoding(UTF-8)", "${outputDIR}/${gdfFileName}.gdf") or die $!;
    print OUT @headerInfo; # Insert header info in every file.
    print OUT @gdfFileInfo; # Insert section info.
    close OUT or die $!; # Close output file.       
}

exit 0;