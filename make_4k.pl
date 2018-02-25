#!perl
# The script will resize images in parallel up to MaxParallel.
use strict;
use warnings;
use File::Basename;
use Parallel::ForkManager;
use Benchmark;
my $DEBUG = 0;
my $MaxParallel = 14;

my $image_dir = "c:/your/images/path";
my $dest_dir = "4k";
my $cur_pict = "";
my $image_magic_location = "c:/Program Files/Imagemagick-7.0.2-Q16";
my $full_dest = "$image_dir\\$dest_dir";
# Check for destination directory
unless(-d $full_dest) {
	mkdir $full_dest or die;
}

my $start = new Benchmark;
# get the jpegs in the directory
my @files = <$image_dir/*.jpg>;
#my @files = <$image_dir/*.tif>;
my $pm;
$pm = new Parallel::ForkManager($MaxParallel);
foreach my $cur_file (@files) {
	if($DEBUG) {print "Current file is $cur_file\n";}
	my ($file_base, $dir_name, $file_exteniton) = fileparse($cur_file, ('\.jpg') );
	#my ($file_base, $dir_name, $file_exteniton) = fileparse($cur_file, ('\.tif') );
	# create the system command
	# gravity can be Center, North, South, East, West
	my $command = '"' . "$image_magic_location\\magick" . '" ' . 
				'"' . "$cur_file" . '" -resize "3840x2160^"' .
				" -gravity Center -crop 3840x2160+0+0 +repage " .  
				"$full_dest" . "\\" . "$file_base" . ".jpg" . '"';
	if($DEBUG) {print "$command\n";}
	# Call image magic in the background
	$pm->start and next;
	my $output = `$command`;
	if($DEBUG) {print $output;}
	$pm->finish;
}
$pm->wait_all_children;
my $end = new Benchmark;
my $diff = timediff($end, $start);
print "Time taken was ", timestr($diff, 'all'), " seconds\n";

exit(0);
