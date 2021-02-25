#!/usr/bin/perl

require 'getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";
$itemNoteTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/item-note-types?query=id="*"`;
$hash = decode_json $itemNoteTypes;
for ( @{$hash->{itemNoteTypes}} ) {
	$name = $_->{'name'};
	$source = $_->{'source'};
	push(@tableData,"$name|$source");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$itemNoteTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/item-note-types?query=id="*"`;
$hash = decode_json $itemNoteTypes;
for ( @{$hash->{itemNoteTypes}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	print "deleting $name \n";
	$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/item-note-types/$id`;
	print "$delete\n";
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($name,$source) = split(/\|/,$row);
	$json = qq[{"name":"$name","source":"$source"}];
	$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/item-note-types`;
	print "$post \n\n";
}

