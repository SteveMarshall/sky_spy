#!/usr/bin/env perl

use strict;
use warnings;

use Digest::MD5 qw( md5_hex );
use WWW::Curl::Easy;

my $file_url = 'http://movies.apple.com/media/us/ipad/2010/ads/apple-ipad-ad-meet_ipad-us-20100307_848x480.mov';
my $file_md5 = 'a74930b8ff20cc480016086dfd39673d';

sub get_download_speed {
    my $url          = shift;
    my $expected_md5 = shift;
    
    my $curl = new WWW::Curl::Easy;
    
    $curl->setopt( CURLOPT_HEADER, 0 );
    $curl->setopt( CURLOPT_URL, $file_url );
    my $response_body;
    
    # NOTE - do not use a typeglob here. A reference to a typeglob is okay though.
    open ( my $fileb, ">", \$response_body );
    $curl->setopt( CURLOPT_WRITEDATA, $fileb );
    
    # Starts the actual request
    my $retcode = $curl->perform();
    
    # Looking at the results...
    my $md5           = md5_hex( $response_body );
    my $average_speed = 0;
    
    if ( ( $retcode == 0 )
      && ( $expected_md5 eq $md5 )) {
        $average_speed = $curl->getinfo( CURLINFO_SPEED_DOWNLOAD );
    }
    else {
        print( "Curl error: " . $curl->strerror( $retcode ) . " ($retcode)\n" );
    }
    return $average_speed;
}


# Store the start time
use POSIX qw( strftime );
my $start_time = strftime "%Y/%m/%d %T", localtime;

my $average_speed = get_download_speed( $file_url, $file_md5 );

# Log the end time: sometimes the router sits there, doing nothing.
my $end_time = strftime "%Y/%m/%d %T", localtime;

# Log the line of data
my @output = (
    $start_time,
    $end_time,
    $average_speed
);

# Output
my $output_line = join ',', @output;
print $output_line;
