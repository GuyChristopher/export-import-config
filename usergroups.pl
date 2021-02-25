#!/usr/bin/perl

require 'getExportImportTokens.pl'; 

use JSON; 

print "exporting table data \n";

$usergroups = `curl -s -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/groups?query=id="*"`;
$hash = decode_json $usergroups;
for ( @{$hash->{usergroups}} ) {
	$group = $_->{'group'};
	$desc = $_->{'desc'};
	push(@tableData,"$group|$desc");
}
print "@tableData \n\n";

print "deleteing data from the import env \n";
$usergroups = `curl -s -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/groups?query=id="*"`;
$hash = decode_json $usergroups;
for ( @{$hash->{usergroups}} ) {
	$id = $_->{'id'};
	$group = $_->{'group'};
	if ($group =~ /tenant/ || $group =~ /EBSCO/) {
		print "deleting nothing re $group \n";
	} else {
		print "deleting $group \n";
		$delete = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/groups/$id`;
		print "$delete\n";
	}
}

print "\nimporting table data \n\n";
foreach $row (@tableData) {
	($group,$desc) = split(/\|/,$row);
	if ($group =~ /tenant/ || $group =~ /EBSCO/) {
		print "posting nothing re $group \n";
	} else {
		$json = qq[{"group":"$group","desc":"$desc"}];
		$post = `curl -s -w '\n' -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/groups`;
		print "$post \n\n";
	}
}

