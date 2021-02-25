#!/usr/bin/perl

$jsonHeader = "Content-type: application/json";
$xOkapiTenant = "zz1234567890";

$exportPassword = "password"; 
$exportUsername = "username";
$exportURL = "https://okapi-institution.folio.ebsco.com";
$post = `curl -i -s -w '\n' -X POST -H '$jsonHeader' -H 'X-Okapi-Tenant: $xOkapiTenant' -d '{"username": "$exportUsername", "password": "$exportPassword"}' $exportURL/authn/login`;
@parts = split(/\n/,$post);
foreach $part (@parts) {
 if ($part =~ /^x-okapi-token:/) {
  $exportToken = "X-Okapi-Token: " . substr($part,15);
  $exportToken =~ s/^M//; # that is not ^M but rather Ctrl+V Ctrl+M
 }
}

$importPassword = "password"; 
$importUsername = "username";
$importURL = "https://okapi-institution-test.folio.ebsco.com";
$post = `curl -i -s -w '\n' -X POST -H '$jsonHeader' -H 'X-Okapi-Tenant: $xOkapiTenant' -d '{"username": "$importUsername", "password": "$importPassword"}' $importURL/authn/login`;
@parts = split(/\n/,$post);
foreach $part (@parts) {
 if ($part =~ /^x-okapi-token:/) {
  $importToken = "X-Okapi-Token: " . substr($part,15);
  $importToken =~ s/^M//; # that is not ^M but rather Ctrl+V Ctrl+M
 }
}

1;
