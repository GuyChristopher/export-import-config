#!/usr/bin/perl

require 'getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";

$instanceStatuses = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/instance-statuses?query=id="*"`;
$hash = decode_json $instanceStatuses;
for ( @{$hash->{instanceStatuses}} ) {
	$name = $_->{'name'};
	$code = $_->{'code'};
	$source = $_->{'source'};
	push(@tableData,"$name|$code|$source");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$instanceStatuses = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/instance-statuses?query=id="*"`;
$hash = decode_json $instanceStatuses;
for ( @{$hash->{instanceStatuses}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	print "deleting $name \n";
	$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/instance-statuses/$id`;
	print "$delete\n";
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($name,$code,$source) = split(/\|/,$row);
	$json = qq[{"name":"$name","code":"$code","source":"$source"}];
	$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/instance-statuses`;
	print "$post \n\n";
}

