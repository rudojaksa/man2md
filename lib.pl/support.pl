
# --------------------------------------------------------------------------------------------- FUNCS

# inar(\@a,$s) - check whether the string is in the array
sub inar {
  my $a=$_[0]; # array ref
  my $s=$_[1]; # string
  foreach(@{$a}) { return 1 if $_ eq $s; }
  return 0; }

# pushq(\@a,$s) - push unique, only if not there
sub pushq {
  my $a=$_[0]; # array ref
  my $s=$_[1]; # string
  return if inar $a,$s;
  push @{$a},$s; }

# return file name from path
sub fname {
  my $fname = $_[0];
  $fname =~ s/^.*\///;
  return $fname; }
# return directory part of path
sub dirname { return $1 if $_[0] =~ /^(.*)\/[^\/]*$/; }

# writefile
sub writefile {
  my $file = $_[0];
  my $s    = $_[1];
  my $dir  = dirname $file;
  mkdir $dir if not -d $dir;
  open(O,">$file") or die "Can't create file $CG_$file$CD_ $CR_($!)$CD_."; #(writefile)#
  print O $s;
  close(O); }

# read the first line
sub firstline {
  my $file = $_[0];
  my $s;
  open(FILE,"<$file") or die "Can't read file $CG_$file$CD_ $CR_($!)$CD_."; #(firstline)#
  $s = <FILE>;
  close(FILE);
  return $s; }

# ---------------------------------------------------------------------------------------------------

