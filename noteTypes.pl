#!/usr/bin/perl

require 'getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";

$noteTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/note-types?query=id="*"`;
$hash = decode_json $noteTypes;
for ( @{$hash->{noteTypes}} ) {
	$name = $_->{'name'};
	push(@tableData,"$name");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$noteTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/note-types?query=id="*"`;
$hash = decode_json $noteTypes;
for ( @{$hash->{noteTypes}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	print "deleting $name \n";
	$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/note-types/$id`;
	print "$delete\n";
}

print "\nimporting table data \n\n";
foreach $name (@tableData) {
	$json = qq[{"name":"$name"}];
	$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/note-types`;
	print "$post \n\n";
}

