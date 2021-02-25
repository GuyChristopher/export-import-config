#!/usr/bin/perl

require 'getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";

$contributorTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/contributor-types?query=id="*"`;
$hash = decode_json $contributorTypes;
for ( @{$hash->{contributorTypes}} ) {
	$name = $_->{'name'};
	$code = $_->{'code'};
	$source = $_->{'source'};
	push(@tableData,"$name|$code|$source");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$contributorTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/contributor-types?query=id="*"`;
$hash = decode_json $contributorTypes;
for ( @{$hash->{contributorTypes}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	print "deleting $name \n";
	$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/contributor-types/$id`;
	print "$delete\n";
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($name,$code,$source) = split(/\|/,$row);
	$json = qq[{"name":"$name","code":"$code","source":"$source"}];
	$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/contributor-types`;
	print "$post \n\n";
}

