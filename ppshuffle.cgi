#!/usr/bin/perl
# 
use strict;
use warnings;
use PPShuffle;
use CGI::Carp qw(fatalsToBrowser);

my $ppshuffle = PPShuffle->new();
$ppshuffle->run();

