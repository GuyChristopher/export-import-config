#!/usr/bin/perl

require '/opt/folio/exportImportConfig/getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";

$usergroups = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/groups?query=id="*"`;
$hash = decode_json $usergroups;
for ( @{$hash->{usergroups}} ) {
	$id = $_->{'id'};
	$group = $_->{'group'};
	$desc = $_->{'desc'};
	if ($id eq "d8448238-4277-4b92-b906-230c2b36c980" || $id eq "13b36f7a-bd74-43dc-a114-cf6cb31f82f6") {
		$note2self = "do not import this admin group";
	} else {
		push(@tableData,"$id|$group|$desc");
	}
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$usergroups = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/groups?query=id="*"`;
$hash = decode_json $usergroups;
for ( @{$hash->{usergroups}} ) {
	$id = $_->{'id'};
	$group = $_->{'group'};
	if ($id eq "72a8b6ad-e9d4-42ff-a718-03c010d2359c") {
		$note2self = "do not delete this admin group";;
	} else {
		print "deleting $group \n";
		$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/groups/$id`;
		print "$delete\n";
	}
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($id,$group,$desc) = split(/\|/,$row);
	$json = qq[{"id":"$id","group":"$group","desc":"$desc"}];
	$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/groups`;
	print "$post \n\n";
}

