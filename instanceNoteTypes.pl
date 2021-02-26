#!/usr/bin/perl

require '/opt/folio/exportImportConfig/getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";
$instanceNoteTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/instance-note-types?query=id="*"`;
$hash = decode_json $instanceNoteTypes;
for ( @{$hash->{instanceNoteTypes}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	$source = $_->{'source'};
	push(@tableData,"$id|$name|$source");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$instanceNoteTypes = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/instance-note-types?query=id="*"`;
$hash = decode_json $instanceNoteTypes;
for ( @{$hash->{instanceNoteTypes}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	print "deleting $name \n";
	$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/instance-note-types/$id`;
	print "$delete\n";
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($id,$name,$source) = split(/\|/,$row);
	$json = qq[{"id":"$id","name":"$name","source":"$source"}];
	$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/instance-note-types`;
	print "$post \n\n";
}

