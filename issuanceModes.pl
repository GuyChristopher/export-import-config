#!/usr/bin/perl

require 'getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";

$issuanceModes = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/modes-of-issuance?query=id="*"`;
$hash = decode_json $issuanceModes;
for ( @{$hash->{issuanceModes}} ) {
	$name = $_->{'name'};
	$source = $_->{'source'};
	push(@tableData,"$name|$code|$source");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$issuanceModes = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/modes-of-issuance?query=id="*"`;
$hash = decode_json $issuanceModes;
for ( @{$hash->{issuanceModes}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	print "deleting $name \n";
	$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/modes-of-issuance/$id`;
	print "$delete\n";
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($name,$source) = split(/\|/,$row);
	$json = qq[{"name":"$name","source":"$source"}];
	$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/modes-of-issuance`;
	print "$post \n\n";
}

