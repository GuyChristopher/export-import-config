#!/usr/bin/perl

require 'getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";

$instanceTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/instance-types?query=id="*"`;
$hash = decode_json $instanceTypes;
for ( @{$hash->{instanceTypes}} ) {
	$name = $_->{'name'};
	$code = $_->{'code'};
	$source = $_->{'source'};
	push(@tableData,"$name|$code|$source");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$instanceTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/instance-types?query=id="*"`;
$hash = decode_json $instanceTypes;
for ( @{$hash->{instanceTypes}} ) {
	$id = $_->{'id'};
	print "deleting $id \n";
	$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/instance-types/$id`;
	print "$delete\n";
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($name,$code,$source) = split(/\|/,$row);
	$json = qq[{"name":"$name","code":"$code","source":"$source"}];
	$post = `curl -s -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/instance-types`;
	print "$post \n\n";
}

