#!/usr/bin/perl

require '/opt/folio/exportImportConfig/getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";
$addressTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/addresstypes?query=id="*"`;
$hash = decode_json $addressTypes;
for ( @{$hash->{addressTypes}} ) {
	$id = $_->{'id'};
	$addressType = $_->{'addressType'};
	$desc = $_->{'desc'};
	push(@tableData,"$id|$addressType|$desc");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$addressTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/addresstypes?query=id="*"`;
$hash = decode_json $addressTypes;
for ( @{$hash->{addressTypes}} ) {
	$id = $_->{'id'};
	$addressType = $_->{'addressType'};
	print "deleting $addressType \n";
	$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/addresstypes/$id`;
	print "$delete\n";
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($id,$addressType,$desc) = split(/\|/,$row);
	$json = qq[{"id":"$id","addressType":"$addressType","desc":"$desc"}];
	$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/addresstypes`;
	print "$post \n\n";
}

