#
# Sanitize functions
# http://www.ipa.go.jp/security/awareness/vendor/programming/a01_02_main.html
#
package EzSanitize;
use strict;
use warnings;
use encoding 'utf-8';
binmode( STDERR, ':raw :encoding(utf-8)' );

use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(ez_sanitize ez_url_sanitize);
our @EXPORT_OK = qw(ez_sanitize ez_url_sanitize);

sub ez_sanitize {
    my $input = $_[0];
    $input =~ s/&/&amp;/g;
    $input =~ s/</&lt;/g;
    $input =~ s/>/&gt;/g;
    $input =~ s/"/&quot;/g;
    $input =~ s/'/&#39;/g;
    return $input;
}

sub ez_url_sanitize {
    my $url = $_[0];

    ### return null string when url contains unpermitted characters ###
    # --- http://www.ietf.org/rfc/rfc2396.txt ---
    # uric = reserved | unreserved | escaped
    # reserved = ";" | "/" | "?" | ":" | "@" | "&" | "=" | "+" | "$" | ","
    # unreserved = alphanum | mark
    # mark = "-" | "_" | "." | "!" | "~" | "*" | "'" | "(" | ")"
    # escaped = "%" hex hex

    return '' if($url =~ m|[^;/?:@&=+\$,A-Za-z0-9\-_.!~*'()%]|);

    ### return null string if it contains unknown scheme ###
    # --- http://www.ietf.org/rfc/rfc2396.txt ---
    # scheme = alpha *( alpha | digit | "+" | "-" | "." )

    if($url =~ /^([A-Za-z][A-Za-z0-9+\-.]*):/) {
        my $scheme = lc($1);
        my $allowed = 0;
        $allowed = 1 if($scheme eq 'http');
        $allowed = 1 if($scheme eq 'https');
        $allowed = 1 if($scheme eq 'mailto');
        return '' if(not $allowed);
    }

    ### HTML escape ###
    # special = "&" | "<" | ">" | '"' | "'"

    $url =~ s/&/&amp;/g;
    $url =~ s/'/&#39;/g;

    return $url;
}

1;
