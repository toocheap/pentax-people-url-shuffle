#
# PENTAX PEOPLE Shuffle Package
# $Id$
#
package PPShuffle;

use base CGI::Application;
use strict;
use warnings;
use encoding 'utf-8';
binmode( STDERR, ':raw :encoding(utf-8)' );
use Encode;
use DBI;
use BPJsDump;
use Data::Dumper;

our $DBNAME = "ppurl.db";

sub setup {
	my $self = shift;
	$self->start_mode('start');
	$self->run_modes(
		start	=>	"shuffle_mode",
		jump	=>	"jump_uri",
		AUTOLOAD=>	"showerr",
	);
}

sub shuffle_urls {
	my ($self) = @_;
	my $dbh = DBI->connect("dbi:SQLite:dbname=$DBNAME", "", "");
	my $count = $dbh->selectrow_array("SELECT COUNT(*) FROM urls");
	my $row = $dbh->selectrow_hashref("SELECT * FROM urls WHERE id=abs(random() % $count)");
	$dbh->disconnect;
	return $row;	
}

sub shuffle_mode {
	my $self = shift;

	# for change charset
	$self->header_props(-charset => 'utf-8');

	my $selected = $self->shuffle_urls;

	my $template = $self->load_tmpl("./shuffle.tmpl");
	$template->param("URL" => $selected->{url});
	$template->param("DELAYED" => '3');

	return $template->output();
}

sub jump_uri {
	my ($self, $uri) = @_;
	$self->header_type('redirect');
	$self->header_props(-uri => $uri);
	return "Redirect to $uri";
}

# This function must be use template file.
sub showerr {
	my ($self, $errstr) = @_;
	return "Error had occur : $errstr";
}

1;
