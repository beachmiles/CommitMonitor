#!/usr/bin/perl


# Copyright 2013 Tiny Speck, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#
# An SVN post-commit handler for posting to Slack. Setup the channel and get the token
# from your team's services page. Change the options below to reflect your team's settings.
#
# Requires these perl modules:
# HTTP::Request
# LWP::UserAgent
# JSON


# Submits the following post to the slack servers

# POST https: //foo.slack.com/services/hooks/subversion?token=xxxxxx
# Content-Type: application/x-www-form-urlencoded
# Host: foo.slack.com
# Content-Length: 101
#
# payload=%7B%22revision%22%3A1%2C%22url%22%3A%22http%3A%2F%2Fsvnserver%22%2C%22author%22%3A%22digiguru%22%2C%22log%22%3A%22Log%20info%22%7D

use warnings;
use strict;
use HTTP::Request::Common qw(POST);
use HTTP::Status qw(is_client_error);
use LWP::UserAgent;
use JSON;

#
# Customizable vars. Replace these to the information for your team
#
my $opt_domain = "love-perl.slack.com"; # Your team's domain 
my $opt_token = "MdD7b2JS8EIpeEzRhq8vmh6x"; # The token from your SVN services page from Slack


#
# this script gets called by the SVN post-commit handler
# with these args:
#
# [0] URL
# [1] revision committed  
# [2] username
# [3] project
# [4] files
# we need to find out what happened in that revision and then act on it
#

# FOR LINUX USE THESE VARIABLES
#my $log = `/usr/bin/svnlook log -r $ARGV[1] $ARGV[0]`;
#my $who = `/usr/bin/svnlook author -r $ARGV[1] $ARGV[0]`;
#my $dirChanged = `/usr/bin/svnlook  dirs-changed $ARGV[0]`;

# FOR WINDOWS USE THESE VARIABLES
#my $log = `svnlook log -r $ARGV[1] $ARGV[0]`;

#get SVN path of commit
# optionally set this to the url of your internal commit browser. Ex: http://svnserver/wsvn/main/?op=revision&rev=$ARGV[1]
#my $url = "https://12.166.94.37/svn/ACC$ARGV[0]";
my $url = $ARGV[0];
my $log = $ARGV[0];	#just show the log in this section
my $rev = $ARGV[1];
my $author = "";
print STDERR "We have $#ARGV + 1 Arguments\r\n";


#Add rev path to log
#$log = "$url  - $log";
if ( $#ARGV >= 4 ){
	$log = "$ARGV[3] $ARGV[4]";
	$author = $ARGV[2];	 
}
elsif ( $#ARGV >= 3 ){
	$log = "$ARGV[3] $ARGV[0]";
	$author = $ARGV[2];	 
}
elsif ( $#ARGV >= 2 ){
	$log = " $ARGV[0]";
	$author = $ARGV[2];	 
}
else{
	$log = " $ARGV[0]";
	$author = "";	  
}

if ($author  == ""){$author  = "noauth"; }
if ($log  == ""){$log  = "nolog"; }
if ($url  == ""){$url  = "nourl"; }
if ($rev  == ""){$rev  = "norev"; }

my $payload = {
	'revision'	=> $rev,
	'url'		=> $url,
	'author'	=> $author,
	'log'		=> $log,
};


my $now_string = localtime;  # e.g., "Thu Oct 13 04:54:34 1994"
print STDERR "$now_string Payload= rev=$rev url=$url auth=$author log=$log\n";

#Copies to a log in C:\Temp
open(my $fh, '>>', 'C:\Temp\svnSync.log');
print $fh "$now_string rev=$rev url=$url auth=$author log=$log \n";
close $fh;


my $ua = LWP::UserAgent->new;
$ua->timeout(15);

my $req = POST( "https://${opt_domain}/services/hooks/subversion?token=${opt_token}", ['payload' => encode_json($payload)] );
my $s = $req->as_string;
print STDERR "Request:\n$s\n";

my $resp = $ua->request($req);
$s = $resp->as_string;
print STDERR "Response:\n$s\n";
