#!/usr/bin/perl

require '/opt/folio/exportImportConfig/getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";

$instanceFormats = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/instance-formats?query=id="*"`;
$hash = decode_json $instanceFormats;
for ( @{$hash->{instanceFormats}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	$code = $_->{'code'};
	$source = $_->{'source'};
	push(@tableData,"$id|$name|$code|$source");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$instanceFormats = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/instance-formats?query=id="*"`;
$hash = decode_json $instanceFormats;
for ( @{$hash->{instanceFormats}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	print "deleting $name \n";
	$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/instance-formats/$id`;
	print "$delete\n";
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($id,$name,$code,$source) = split(/\|/,$row);
	$json = qq[{"id":"$id","name":"$name","code":"$code","source":"$source"}];
	$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/instance-formats`;
	print "$post \n\n";
}

