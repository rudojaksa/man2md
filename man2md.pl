#!/usr/bin/perl
# Copyleft: R.Jaksa 2018, GNU General Public License version 3
# include "CONFIG.pl"
# ------------------------------------------------------------------------------- HELP

$HELP=<<EOF;

NAME
    man2md - man to (github) markdown convertor

USAGE
    man topic | man2md [OPTIONS]
    or
    man topic > topic.txt
    man2md [OPTIONS] topic.txt > topic.md

DESCRIPTION
    Man2md just converts manpage or an interactive help, if it is man-like
    formatted, into the markdown format suitable for the github CD(README.md).

OPTIONS
      -h  This help.
  -p SEC  Treat a section with name containig the SEC string (glob) as a
          preformatted.  Comma separated list is accepted too.

EOF

# ------------------------------------------------------------------------------ ARGVS
foreach(@ARGV) { if($_ eq "-h") { printhelp $HELP; exit 0; }}

our @PRES;
for($i=0;$i<$#ARGV;$i++) {
  if($ARGV[$i] eq "-p" and $ARGV[$i+1]) {
    push @PRES,$ARGV[$i+1];
    $ARGV[$i]=""; $ARGV[$i+1]=""; }}

our $INPUT;
foreach(@ARGV) {
  next if $_ eq "";
  if(-f $_) { $INPUT=$_; $_=""; last; }}

# ------------------------------------------------------------------------------ INPUT

if(defined $INPUT) {
  $RAW = `cat $INPUT`; }

else {
  while(<STDIN>) {
    $RAW .= "$_"; }}

# ---------------------------------------------------------------------- PREPROCESSING

# remove color escape sequences
$RAW =~ s/\033\[36m//g;	# cyan
$RAW =~ s/\033\[37m//g;	# white
$RAW =~ s/\033\[90m//g;	# black
$RAW =~ s/\033\[0m//g;	# default

# titles
$RAW =~ s/\n([A-Z])/\n\#\#\# $1/g;
$RAW =~ s/\n([A-Za-z0-9-]+(\h+[A-Za-z0-9-]+)?(\h+[A-Za-z0-9-]+)?:)/\n\#\#\#\# $1/g;

# multiple newlines
$RAW =~ s/\n\h*\n\h*(\n\h*)+/\n\n/g;

# --------------------------------------------------------------------- SPLIT SECTIONS

# split into sections
our @HEAD; # header text
our %HDPX; # header prefix
our %BODY; # section body
sub addsec { push @HEAD,$_[0]; $HDPX{$_[0]} = $_[1]; $BODY{$_[0]} = $_[2]; }

my $head; # current header
my $hdpx; # header prefix
my $body; # current body
foreach my $s (split /\n/,$RAW) {

  # header => store past section
  if($s =~ /^(\#\#*) (.*)\h*$/) {
    addsec $head,$hdpx,$body and undef $body if defined $head and defined $body;
    $head = $2;
    $hdpx = $1; }

  # just line
  else {
    $body .= "$s\n" if defined $head; }} # store the body only for recognized head

addsec $head,$hdpx,$body if defined $head and defined $body;
# print "$_\n$BODY{$_}" foreach @HEAD; exit 1;

# --------------------------------------------------------------------- SECTIONS TYPES

# list of sections always treated as regular
$REG=<<EOF;
NAME
DESCRIPTION
VERSION
AUTHOR
REPORTING BUGS
COPYRIGHT
SEE ALSO
EOF
our @REG = split /\n/,$REG;

# list of sections always treated as preformatted
$PRE=<<EOF;
USAGE
OPTIONS
SYNOPSIS
EXAMPLES
EXAMPLE
EOF
our @PRE = split /\n/,$PRE;

# preformatted, as requested from commandline
our @PRESRE;
foreach my $pres (@PRES) {
  foreach my $s (split /,/,$pres) {
    $s =~ s/\*/.*/g;
    $s =~ s/\?/./g;
    push @PRESRE,"^$s\$"; }}
# foreach(@PRESRE) { print " -- $_\n"; } exit;

sub presre {
  my $s = $_[0];
  foreach my $re (@PRESRE) {
    return 1 if $s =~ /$re/; }
  return 0; }

our %TYPE; # 1=REG 2=PRE
foreach my $h (@HEAD) {
  if(presre $h) { $TYPE{$h}=2; } # requested to be preformatted
  elsif(inar \@REG,$h) { $TYPE{$h}=1; } # always regular
  elsif(inar \@PRE,$h) { $TYPE{$h}=2; } # always preformatted
  elsif($BODY{$h}=~/(^|\n)\h*-[a-zA-Z0-9]/) { $TYPE{$h}=2; } # seems, list of options included
  elsif($BODY{$h}=~/(^|\n)\h*+[a-zA-Z0-9]/) { $TYPE{$h}=2; } # seems, list of + options included
  else { $TYPE{$h}=1; }} # default regular
# print "$_ $TYPE{$_}\n" foreach @HEAD;

# ----------------------------------------------------------------- INDENTATION PREFIX

my $ind = 1000; # total minimal indentation level
foreach my $h (@HEAD) {
  next if not $TYPE{$h} == 2;
  foreach my $s (split /\n/,$BODY{$h}) {
    next if $s =~ /^\h*$/; # skip empty lines
    if($s =~ /^( *)/) {
      my $len = length $1;
      $ind = $len if $len < $ind; }}}

my $px = ""; # required prefix to maintain minimal indentatiot to be four
for(my $i=0; $i<4-$ind; $i++) { $px.=" "; }
# print "max ind: $ind\n";

# -------------------------------------------------------------------- ASSEMBLE OUTPUT

our $OUT; # output string
foreach my $h (@HEAD) {

  # header
  $OUT .= "$HDPX{$h} $h\n";

  # regular text
  if($TYPE{$h} == 1) {
    my $sp; # indentation space in current regular section input
    foreach my $s (split /\n/,$BODY{$h}) {
      $sp = $1 if not defined $sp and $s=~/^( *)[^ ]/; # only for 1st line
      $s =~ s/^$sp//; # remove indentation here
      $OUT .= "$s\n"; }}
      
  # preformatted text
  elsif($TYPE{$h} == 2) {
    foreach my $s (split /\n/,$BODY{$h}) {
      $OUT .= "$px$s\n"; }}

  $OUT .= "\n"; }

# ----------------------------------------------------------------------------- OUTPUT

print "$OUT";

# ------------------------------------------------------------------------------------
