use strict;
use warnings;
use LWP::Simple;
use JSON;

my $debug = 1;
my @Query_Years = ( 2019 );
print STDOUT "FiscalYear,State,Zip,City,DestinationID,LocationDefined,Meals,Oct,Nov,Dec,Jan,Feb,Mar\n";

# shorter list
#my @States = qw( AL AZ CA CO CT DC FL GA IA IL IN KS KY MA MD MI MO MS NC NH NJ NM NV NY OH OK OR PA RI SC TN TX UT VA WA );
# full state list
my @States = qw( AL AK AZ AR CA CO CT DE DC FL GA HI ID IA IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WV WI WY );
#my @States = qw( OK ); # for testing
#Extras: AS GU MH FM MP PW PR VI	
#American Samoa, Guam, Marshall Islands, Micronesia, Northern Marianas, Palau, Puerto Rico, Virgin Islands



foreach my $Query_Year ( @Query_Years ) {

	print STDERR "Year=$Query_Year\n" if $debug;

	foreach my $State ( @States ) {

		print STDERR "State=$State\n" if $debug;
		#next;

		my $Query_String = qq[https://inventory.data.gov/api/action/datastore_search?resource_id=8ea44bc4-22ba-4386-b84c-1494ab28964b&limit=300000&filters={"FiscalYear":"$Query_Year","State":"$State"}];
		
		print STDERR "Query_String=$Query_String\n" if $debug;
		
		my $json_data = get( $Query_String );
		my $json_obj = new JSON;
		my $perl_data = $json_obj->decode($json_data);

		print STDERR "perl_data[success]=$perl_data->{success}\n" if $debug > 2;
		print STDERR "perl_data[result][total]=$perl_data->{result}{total}\n" if $debug > 2;
		print STDERR $json_obj->pretty->encode($perl_data) if $debug > 3;
		#print STDERR $perl_data->{result}{records} if $debug > 2;
		
		if ( $perl_data->{success} ) {
			foreach my $records ( $perl_data->{result}{records} ) {
				foreach my $record ( @{$records} ) {
					#print "$field\n";
					if ( length(${$record}{Zip}) == 4 ) {
						${$record}{Zip} = "0" . ${$record}{Zip};
					}
					print STDOUT join( ",",
						${$record}{FiscalYear},
						${$record}{State},
						'"' . ${$record}{Zip} . '"',
						'"' . ${$record}{City} . '"',
						${$record}{DestinationID},
						'"' . ${$record}{LocationDefined}. '"',
						${$record}{Meals},
						${$record}{Oct},
						${$record}{Nov},
						${$record}{Dec},
						${$record}{Jan},
						${$record}{Feb},
						${$record}{Mar}) . "\n" ;
					#foreach my $field ( sort keys %{$record} ) {
					#	print "$field:${$record}{$field}\n";
					#}
				}
			}
		}
		else {
			print STDERR "No records returned\n" if $debug;
		}
	}
}
