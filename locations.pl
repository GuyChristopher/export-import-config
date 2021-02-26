#!/usr/bin/perl

require '/opt/folio/exportImportConfig/getExportImportTokens.pl';

use JSON;

$locinsts = `curl -s -w '\n' -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/location-units/institutions?query=id="*"`;
$hash = decode_json $locinsts;
for ( @{$hash->{locinsts}} ) {
	$code = $_->{'code'};
	$id = $_->{'id'};
	$name = $_->{'name'};
	push(@locinstsData,"$id|$name|$code");
}

$loccamps = `curl -s -w '\n' -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/location-units/campuses?query=id="*"`;
$hash = decode_json $loccamps;
for ( @{$hash->{loccamps}} ) {
	$code = $_->{'code'};
	$id = $_->{'id'};
	$institutionId = $_->{'institutionId'};
	$name = $_->{'name'};
	push(@loccampsData,"$id|$name|$code|$institutionId");
}

$loclibs = `curl -s -w '\n' -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/location-units/libraries?query=id="*"`;
$hash = decode_json $loclibs;
for ( @{$hash->{loclibs}} ) {
	$campusId = $_->{'campusId'};
	$code = $_->{'code'};
	$id = $_->{'id'};
	$name = $_->{'name'};
	push(@loclibsData,"$id|$name|$code|$campusId");
}

$servicepoints = `curl -s -w '\n' -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/service-points?query=id="*"`;
$hash = decode_json $servicepoints;
for ( @{$hash->{servicepoints}} ) {
	$code = $_->{'code'};
	$discoveryDisplayName = $_->{'discoveryDisplayName'};
	$id = $_->{'id'};
	$name = $_->{'name'};
	push(@servicepointsData,"$id|$name|$code|$discoveryDisplayName");
}

$locations = `curl -s -w '\n' -X GET -G -H '$jsonHeader' -H '$exportToken' -d 'limit=1000' $exportURL/locations?query=id="*"`;
$hash = decode_json $locations;
for ( @{$hash->{locations}} ) {
	$campusId = $_->{'campusId'};
	$code = $_->{'code'};
	$discoveryDisplayName = $_->{'discoveryDisplayName'};
	$id = $_->{'id'};
	$institutionId = $_->{'institutionId'};
	$libraryId = $_->{'libraryId'};
	$name = $_->{'name'};
	$primaryServicePoint = $_->{'primaryServicePoint'};
	$servicePoints = "";
        $servicePointIds = $_->{'servicePointIds'};
        for ( @{$servicePointIds} ) {
		$servicePoints .= $_ . "|";
	}
	$servicePoints =~ s/\|$//;
	push(@locationsData,"$id|$name|$code|$discoveryDisplayName|$libraryId|$campusId|$institutionId|$primaryServicePoint|$servicePoints");
}

$locations = `curl -s -w '\n' -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/locations?query=id="*"`;
$hash = decode_json $locations;
for ( @{$hash->{locations}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	$deleteLocations = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/locations/$id`; 
	print "delete $name $deleteLocations \n\n";
}

$servicepoints = `curl -s -w '\n' -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/service-points?query=id="*"`;
$hash = decode_json $servicepoints;
for ( @{$hash->{servicepoints}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	$deleteServicepoints = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/service-points/$id`; 
	print "delete $name $deleteServicepoints \n\n";
}

$loclibs = `curl -s -w '\n' -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/location-units/libraries?query=id="*"`;
$hash = decode_json $loclibs;
for ( @{$hash->{loclibs}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	$deleteLoclibs = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/location-units/libraries/$id`; 
	print "delete $name $deleteLoclibs \n\n";
}

$loccamps = `curl -s -w '\n' -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/location-units/campuses?query=id="*"`;
$hash = decode_json $loccamps;
for ( @{$hash->{loccamps}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	$deleteLoccamps = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/location-units/campuses/$id`; 
	print "delete $name $deleteLoccamps \n\n";
}

$locinsts = `curl -s -w '\n' -X GET -G -H '$jsonHeader' -H '$importToken' -d 'limit=1000' $importURL/location-units/institutions?query=id="*"`;
$hash = decode_json $locinsts;
for ( @{$hash->{locinsts}} ) {
	$id = $_->{'id'};
	$name = $_->{'name'};
	$deleteLocinsts = `curl -s -X DELETE -H '$jsonHeader' -H '$importToken' $importURL/location-units/institutions/$id`; 
	print "delete $name $deleteLocinsts \n\n";
}

foreach $institution (@locinstsData) {
	($id,$name,$code) = split(/\|/,$institution);
	$json = qq[{"id":"$id","name":"$name","code":"$code"}];
	$postLocinsts = `curl -s -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/location-units/institutions`;
	print "post $name $postLocinsts \n\n";
}

foreach $campus (@loccampsData) {
	($id,$name,$code,$institutionId) = split(/\|/,$campus);
	$json = qq[{"id":"$id","name":"$name","code":"$code","institutionId":"$institutionId"}];
	$postLoccamps = `curl -s -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/location-units/campuses`;
	print "post $name $postLoccamps \n\n";
}

foreach $library (@loclibsData) {
	($id,$name,$code,$campusId) = split(/\|/,$library);
	$json = qq[{"id":"$id","name":"$name","code":"$code","campusId":"$campusId"}];
	$postLoclibs = `curl -s -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/location-units/libraries`;
	print "post $name $postLoclibs \n\n";
}

foreach $servicepoint (@servicepointsData) {
	($id,$name,$code,$discoveryDisplayName) = split(/\|/,$servicepoint);
	$json = qq[{"id":"$id","name":"$name","code":"$code","discoveryDisplayName":"$discoveryDisplayName"}];
	$postServicepoints = `curl -s -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/service-points`;
	print "post $name $postServicepoints \n\n";
}

foreach $location (@locationsData) {
	@locationInfo = split(/\|/,$location);
	$id = $locationInfo[0];
	$name = $locationInfo[1];
	$code = $locationInfo[2];
	$discoveryDisplayName = $locationInfo[3];
	$libraryId = $locationInfo[4];
	$campusId = $locationInfo[5];
	$institutionId = $locationInfo[6];
	$primaryServicePointId = $locationInfo[7];
	$servicePointIds = "";
	for ($x = 8; $x <= $#locationInfo; $x++) {
		if (length($locationInfo[$x]) > 0) {
			$servicePointIds = qq["] . $locationInfo[$x] . qq[",];
		}
	}
	chop($servicePointIds);
	$json = qq/{
	"id":"$id",
	"name":"$name",
	"code":"$code",
	"isActive":true,
	"discoveryDisplayName":"$discoveryDisplayName",
	"institutionId":"$institutionId",
	"campusId":"$campusId",
	"libraryId":"$libraryId",
	"primaryServicePoint":"$primaryServicePointId",
	"servicePointIds":[$servicePointIds]
	}/;
	$postLocations = `curl -s -X POST -H '$jsonHeader' -H '$importToken' -d '$json' $importURL/locations`;
	print "post $name $postLocations\n\n";
}

