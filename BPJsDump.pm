#
# BlogPeople JS file to array which include hash references.
# Author: Tomoyuki MATSUDA <toocheap@gmai.com>
# $Id$
#
package BPJsDump;
use strict;
use warnings;
use encoding 'utf-8';
use Encode;
binmode( STDERR, ':raw :encoding(utf-8)' );
use LWP::UserAgent;
use Storable;
use URI::Escape;
use Digest::MD5 qw(md5_hex);
use FileHandle;
use DateTime;
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(get_js);
our @EXPORT_OK = qw(get_js);

my $bp_regex = qr|href='http://www\.blogpeople\.net/cgi-bin/click\.cgi\?u=([^']+)'.*title='([^'>]+)'\s*>([^<]+)</a>|;
my $bp_pp_uri = q|http://www.blogpeople.net/display/usr/0f0d41595f5b1412.js|;

# separate this as function, it will be changed database access
sub add_site {
	my ($list, $title, $url, $updated) = @_;
	push @$list, {
		title	=>	$title,
		htmlurl	=>	$url,
		updated	=>	jstime2epoc($updated),
	};
}
sub jstime2epoc {
        my $time = shift;
        $time =~ m!(\d\d)\D+(\d\d)\D+(\d\d)\S+\s(\d\d)\D(\d\d)!;
        my $epoc = DateTime->new(
                year    =>      '20' . $1,
                month   =>      $2,
                day     =>      $3,
                hour    =>      $4,
                minute  =>      $5,
                time_zone => 'Asia/Tokyo',
        )->epoch;
        return $epoc;
}


sub get_js {
	my ($ppuri, $mirror_dir) = @_;
	my @urls;
	my $document;

	# If js URI is not provided, use PP.JS as default.
	if (!defined $ppuri) {
		$ppuri = $bp_pp_uri;
	} else {
		require EzSanitize;
		my $sanitized = ez_url_sanitize($ppuri);
		die "Incoming URI is not correct one" if (!defined $sanitized);
		$ppuri = $sanitized;
	}

	# If mirror DIR is not provided, use "./mirror/" as default.
	# TODO:
	# - path delimiter depends on UNIX.
	$mirror_dir = "./mirror/" if (!defined $mirror_dir);

        my $ua = LWP::UserAgent->new
		or die "Cannot create UA : $@";

	if (! -d $mirror_dir) {
		mkdir $mirror_dir, 0777
			or die $!;
	}

	my $digest = Digest::MD5->new()->add($ppuri)->hexdigest();
	# TODO: path delimiter depends on UNIX.
        my $mirrorfile = $mirror_dir . $digest;
        my $res = $ua->mirror($ppuri, $mirrorfile);
	die "Can't mirror URI : ", $res->status_line if $res->is_error;
	do {
		my $fh = FileHandle->new($mirrorfile)
			or die "Cannot open $mirrorfile : $!";
		local $/; # Set Slurp mode
		$document = $fh->getline;
		$fh->close;
	};
	die "Error occured when prceccing a mirror file : $!" if ($@);

	$document = decode("utf-8", $document);
        my @lines = split /\n/, $document;

        for my $line (@lines) {
                $line = uri_unescape($line);
                $line =~ s/\\'/'/g;

                if ($line =~ $bp_regex) {
			add_site(\@urls, $3, $1, $2);
                } else {
                        next;
                }
        }
	\@urls;
}


1;
