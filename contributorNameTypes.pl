#!/usr/bin/perl

require 'getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";

$contributorNameTypes = `curl -s -w '\n' -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/contributor-name-types?query=id="*"`;
$hash = decode_json $contributorNameTypes;
for ( @{$hash->{contributorNameTypes}} ) {
	$name = $_->{'name'};
	$ordering = $_->{'ordering'};
	push(@tableData,"$name|$ordering");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$contributorNameTypes = `curl -s -w '\n' -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/contributor-name-types?query=id="*"`;
$hash = decode_json $contributorNameTypes;
for ( @{$hash->{contributorNameTypes}} ) {
	$id = $_->{'id'};
	print "deleting $id \n";
	$delete = `curl -s -w '\n' -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/contributor-name-types/$id`;
	print "$delete\n";
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($name,$number) = split(/\|/,$row);
	$json = qq[{"name":"$name","ordering":"$number"}];
	$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/contributor-name-types`;
	print "$post \n\n";
}

