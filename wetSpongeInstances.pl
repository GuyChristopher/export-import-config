#!/usr/bin/perl

require 'getExportImportTokens.pl'; 

use JSON; 

print "deleting items... \n";
$delete = `curl -s -X DELETE -G -H '$jsonHeader' -H '$importToken' $importURL/item-storage/items`;
print "$delete \n";

print "deleting holdingsRecords... \n";
$delete = `curl -s -X DELETE -G -H '$jsonHeader' -H '$importToken' $importURL/holdings-storage/holdings`;
print "$delete \n";

print "deleting instances... \n";
$delete = `curl -s -X DELETE -G -H '$jsonHeader' -H '$importToken' $importURL/instance-storage/instances`;
print "$delete \n";

