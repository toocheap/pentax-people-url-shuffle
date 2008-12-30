#!/usr/bin/perl

use strict;
use WWW::Mechanize;

my $account = 'your account';
my $password = 'your password';

my $start = 'http://a.hatena.ne.jp/login';

my $mech = WWW::Mechanize->new();
$mech->agent_alias('Windows IE 6');
$mech->get($start);

$mech->form_number(2);
$mech->field(key => $account);
$mech->field(password => $password);
$mech->click();

$mech->follow_link(url_regex => qr/\.\/edit/);

while (<>) {
        my $url = $_;
        print $url;
        chomp($url);
        $mech->form_number(2);
        $mech->field(pageurl => $url);
        $mech->click();
}

print $mech->content();

