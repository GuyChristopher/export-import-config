#!/usr/bin/perl

require '/opt/folio/exportImportConfig/getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";

$loantypes = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/loan-types?query=id="*"`;
$hash = decode_json $loantypes;
for ( @{$hash->{loantypes}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	push(@tableData,"$id|$name");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$loantypes = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/loan-types?query=id="*"`;
$hash = decode_json $loantypes;
for ( @{$hash->{loantypes}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	print "deleting $name \n";
	$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/loan-types/$id`;
	print "$delete\n";
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($id,$name) = split(/\|/,$row);
	$json = qq[{"id":"$id","name":"$name"}];
	$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/loan-types`;
	print "$post \n\n";
}

