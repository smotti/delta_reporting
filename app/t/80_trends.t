use Test::More;
use Test::Mojo;
use Storable;

$data_file = '/tmp/delta_reporting_test_data';
my $stored = retrieve( $data_file ) or die "Cannot open [$data_file], [$!]";

# This regex is taken from Regexp::Common::number
my $real_number = qr/
   (?:(?i)(?:[-+]?)(?:(?=[.]?[0123456789])(?:[0123456789]*)(?:(?:[.])
   (?:[0123456789]{0,}))?)(?:(?:[E])(?:(?:[-+]?)(?:[0123456789]+))|))
/x;
#$real_number = qr/./;

my $stats_table_body_regex = qr(
   <td>\s*Correlation\s*</td>
   .*
   <td>\s*$real_number\s*</td>
   .*
   <td>\s*Intercept\s*</td>
   .*
   <td>\s*$real_number\s*</td>
   .*
   <td>\s*Slope\s*</td>
   .*
   <td>\s*$real_number\s*</td>
   .*
   <td>\s*Stderr\s*</td>
   .*
   <td>\s*$real_number\s*</td>
)misx;

my $t = Test::Mojo->new('DeltaR');
$t->ua->max_redirects(1);

my %trends = (
   kept     => 'kept',
   notkept  => 'not kept',
   repaired => 'repaired'
);

for my $report ( keys %trends )
{
   my $promise_column = qr/$trends{$report}/i;

   $t->get_ok("/trend/$report")
      ->status_is(200)

      ->element_exists( 'html head title' => "promises $trends{$report} trend",
         "/trend/$report has wrong title" )

      ->content_like( qr(
         <th>Promises</th>
         .*
         <th>Value</th>
         .*
         $stats_table_body_regex
         )misx, "/trend/$report Promises stats table" )
    
      ->content_like( qr(
         <th>Hosts</th>
         .*
         <th>Value</th>
         .*
         $stats_table_body_regex
         )misx, "/trend/$report Hosts stats table" )
      
      ->content_like( qr(
         <th.*?>\s*Date\s*</th>
         .*
         <th.*?>\s*Hosts\s*</th>
         .*
         <th.*?>\s*$promise_column\s*</th>
         .*
         <td>$stored->{data}{datestamp_yesterday}</td>
      )misx, "/trend/$report Raw data" )

      ->text_like( 'html body div script' => qr/dataTable/,
         "/trend/$report dataTable script" )

      ->content_like( qr(var\s+dr_data\s+=\s+\[\{\S*"slope":$real_number)msix,
         "trend/$report dr_data javascript variable");
}

done_testing();

=pod

=head1 SYNOPSIS

This is for testing the trend reports.

=head2 Requirements

Relies on the test data inserted in the database in a previous test.

=head1 LICENSE

Delta Reporting is a central server compliance log that uses CFEngine.

Copyright (C) 2013 Evolve Thinking http://evolvethinking.com

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=cut
