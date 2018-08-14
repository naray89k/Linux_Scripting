#! /usr/local/bin/perl

use Cwd 'abs_path';
use strict;
use warnings;
use MIME::Lite;


sub usage{
	print("perl $_[0] <SMTP_HOSTNAME> <FROM_ADDRESS> <TO_ADDRESS(ES)> <SUBJECT> <HTMLFILE NAME>"); 
}

if (scalar(@ARGV) != 5){
	&usage;
	exit;
}


# GLOBAL VARIABLES:
#my ($smtp_host,$sender,$recipient,$subject,$htmlfile)=@ARGV;
my $smtp_host=$ARGV[0];
my $sender=$ARGV[1];
my $recipient=$ARGV[2];
my $subject=$ARGV[3];
my $htmlfile=$ARGV[4];
die ("cannot open htmlfile $htmlfile\n") unless (open(HTMLFILE,$htmlfile));
my @contents = <HTMLFILE>;
#print (@contents);
my $data = join('',@contents);
#print "$data\n";
my $scriptName=abs_path($0);
my $mime = MIME::Lite->new(
	'From'    => $sender,
	'To'      => $recipient,
	'Subject' => $subject,
	'Type'    => 'text/html',
	'Data'    => $data,
	);

$mime->send('smtp',$smtp_host,Debug=>0)
