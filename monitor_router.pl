#!/usr/bin/env perl

use strict;
use warnings;


use LWP::UserAgent;
my $user_agent = LWP::UserAgent->new();

$user_agent->credentials(
    '192.168.0.1:80',   # location
### Apparently this /isn't/ entirely ignored when authing with my router.
### I was getting shedloads of 401s with this set to 'Realm'; changed it to
### this out of sheer frustration, and it worked!
    'DSL Router',       # ignored for basic auth
    'admin',            # username
    'sky',              # password
);

# Pages to query
my %status = (
    connection => {
        url => 'http://192.168.0.1/sky_st_poe.html',
    },
    router => {
        url => 'http://192.168.0.1/sky_system.html',
    }
);

# Store the start time
use POSIX qw( strftime );
my $start_time = strftime "%Y/%m/%d %T", localtime;

# Grab the router data
foreach my $key ( keys %status ) {
    my $url      = $status{ $key }{'url'};
    my $response = $user_agent->get( $url );
    
    die $response->status_line
        if !$response->is_success();
    
    $status{ $key }{'response'} = $response->decoded_content();
}


my %stats = (
    downstream => {},
    upstream   => {},
    connection => {},
);

# Scrape connection speeds
# <th>Connection Speed</th>
# <td>19131 kbps</td>
# <td>968 kbps</td>
sub extract_downup_from_row {
    my $html       = shift;
    my $row_header = shift;
    my $key        = shift;
    
    ### Lack of /g here threw me awhile on the sibling method. I could
    ### probably join the two, but whatever.
    $row_header =~ s{\s+}{\\s+};
    
    ### Turns out named matches are a feature of 5.10, so I had to revert.
    my $extract_data_from_row = qr{
            <th [^>]* >${row_header}</th> \s* 
            <td [^>]* >( \d+ ) .*? </td> \s*
            <td [^>]* >( \d+ ) .*? </td>
        }x;
    
    if ( $html =~ $extract_data_from_row ) {
        ### I'm too lazy to fix the global usage here at the moment. Fuck it.
        $stats{'downstream'}{ $key } = $1;
        $stats{'upstream'  }{ $key } = $2;
    }
}

extract_downup_from_row( 
    $status{ 'router' }{'response'},
    'Connection Speed', 
    'speed'
);
extract_downup_from_row( 
    $status{ 'router' }{'response'},
    'Noise Margin', 
    'noise'
);
extract_downup_from_row( 
    $status{ 'router' }{'response'},
    'Line Attenuation', 
    'attenuation'
);


# ... connection time et al.
# <th width="50%">Connection Time</th>
# <td width="50%">00:44:43</td
sub extract_connection_data_from_row {
    my $html       = shift;
    my $row_header = shift;
    my $key        = shift;
    
    $row_header =~ s{\s+}{\\s+}g;
    
    my $extract_data_from_row = qr{
            <th [^>]* >${row_header}</th> \s* 
            <td [^>]* >( .+ )</td>
        }x;
    
    if ( $html =~ $extract_data_from_row ) {
        $stats{'connection'}{ $key } = $1;
    }
}

extract_connection_data_from_row(
    $status{ 'connection' }{'response'},
    'Connection Time',
    'time',
);
extract_connection_data_from_row(
    $status{ 'connection' }{'response'},
    'Getting IP Address',
    'ip_address',
);
extract_connection_data_from_row(
    $status{ 'connection' }{'response'},
    'Connecting to Server',
    'connected',
);
extract_connection_data_from_row(
    $status{ 'connection' }{'response'},
    'Negotiation',
    'negotiation',
);
extract_connection_data_from_row(
    $status{ 'connection' }{'response'},
    'Authentication',
    'authentication',
);

# Log the end time: sometimes the router sits there, doing nothing.
my $end_time = strftime "%Y/%m/%d %T", localtime;

# Log the line of data
my @output = (
    $start_time,
    $end_time,
    # Connection state
    $stats{'connection'}{'connected'} || '',
    $stats{'connection'}{'negotiation'} || '',
    $stats{'connection'}{'authentication'} || '',
    $stats{'connection'}{'time'} || '',
    $stats{'connection'}{'ip_address'} || '',
    # Speeds
    $stats{'downstream'}{'speed'} || '',
    $stats{'upstream'}  {'speed'} || '',
    # Noise
    $stats{'downstream'}{'attenuation'} || '',
    $stats{'upstream'}  {'attenuation'} || '',
    $stats{'downstream'}{'noise'} || '',
    $stats{'upstream'}  {'noise'} || '',
);

# Output
my $output_line = join ',', @output;
print $output_line;
