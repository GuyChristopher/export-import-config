#!/usr/bin/perl

require 'getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";

$alternativeTitleTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/alternative-title-types?query=id="*"`;
$hash = decode_json $alternativeTitleTypes;
for ( @{$hash->{alternativeTitleTypes}} ) {
	$name = $_->{'name'};
	$source = $_->{'source'};
	push(@tableData,"$name|$source");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$alternativeTitleTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/alternative-title-types?query=id="*"`;
$hash = decode_json $alternativeTitleTypes;
for ( @{$hash->{alternativeTitleTypes}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	print "deleting $name \n";
	$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/alternative-title-types/$id`;
	print "$delete\n";
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($name,$source) = split(/\|/,$row);
	$json = qq[{"name":"$name","source":"$source"}];
	$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/alternative-title-types`;
	print "$post \n\n";
}
