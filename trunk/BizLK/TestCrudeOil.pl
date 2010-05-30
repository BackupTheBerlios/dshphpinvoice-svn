# 
# $URL:  $
# $Date:  $
# $Revision:  $
# $Author:  $
# $LastChangedDate:  $
#
#  $
# 
 
 
 # Early in your program:
  
   use strict;
   use warnings;

   use LWP::UserAgent;
#   use LWP::Authen::NTLM;
   
   use HTTP::Cookies;
   use HTTP::Request::Common;  
   use Net::HTTP;
   use HTML::TagParser ;
   
  use LWP::Debug qw(+); 
  use Data::Dumper;


sub LoackerCrudeOil;


my %l_MapData = ( Frtt 		=> 'Hazrad'
					,UsDollar	=> '8888'
					,CrudeOil	=> '23');
my $l_hashref = \%l_MapData;

LoackerCrudeOil( $l_hashref );

$l_MapData{EuroPerLiter} = sprintf('%3.4f',int($l_MapData{CrudeOil}) *  int($l_MapData{EuroUsd})/ 158.9873);

print Dumper( $l_hashref );

sub LoackerCrudeOil
{
  # Loads all important LWP classes, and makes
  #  sure your version is reasonably recent.
	my $l_Val_arg = pop;
	
  my $browser = new LWP::UserAgent(keep_alive=>1);
  $browser->agent('Mozilla/5.5 (compatible; MSIE 5.5; Windows NT 5.1)');

   
  my $cookie_jar = HTTP::Cookies->new( ); # allow cookie page
	$browser->cookie_jar( $cookie_jar );
	$browser->max_size( 128 * 1024 );		# 128 KBytes
	$browser->timeout( 10 );				# 10 seconds timeout 

  my $url = 'http://finance.yahoo.com/q/bc?s=CLM10.NYM&t=1d';

  my $response = $browser->get($url);

  die "RT Can't get $url -- ", $response->status_line
   unless $response->is_success;

  die "Hey, I was expecting HTML, not ", $response->content_type
   unless $response->content_type eq 'text/html';


   
    my $html = HTML::TagParser->new( $response->content );
   undef $response;
	
    my $l_TradeTime  = $html->getElementById( "yfs_t10_clm10.nym" )->innerText();
    my $l_TradeValue = $html->getElementById( "yfs_l10_clm10.nym" )->innerText();
    
	
    
	my ($sec,$min,$hour,$day,$month,$yr19,@rest) =   localtime(time);
	my $timeString = sprintf("%04d%02d%02dT%02d:%02d:%02d", 1900+$yr19, $month+1, $day,  $hour, $min, $sec);
	
    my $l_line = "";
    $l_line = "CrudeOilBarrel TradeTime: $timeString TradeValue: $l_TradeValue \n";
    print  $l_line; 
	$l_Val_arg->{'CrudeOil'} = $l_TradeValue;
	
	$url = 'http://finance.yahoo.com/q/bc?s=EURUSD=X&t=1d';
	$response = $browser->get($url);

  die "RT Can't get $url -- ", $response->status_line
   unless $response->is_success;

  die "Hey, I was expecting HTML, not ", $response->content_type
   unless $response->content_type eq 'text/html';

	$html->parse( $response->content );
	
	$l_TradeValue = $html->getElementById( "yfs_l10_eurusd=x" )->innerText();
	$l_Val_arg->{'EuroUsd'} = $l_TradeValue;
	$l_Val_arg->{'Time'} = $timeString;
      undef $browser;
	undef $html;
#
}
