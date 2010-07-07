use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name       => 'File::CodeSearch',
	license           => 'perl',
	dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
	dist_version_from => 'lib/File/CodeSearch.pm',
	requires          => {
		perl              => 5.006,
		'Carp'            => 0,
		'Clone'           => 0,
		'Config::General' => 0,
		'File::chdir'     => 0,
		'File::Slurp'     => 0,
		'File::Basename'  => 0,
		'File::Spec'      => 0,
		'File::chdir'     => 0,
		'IO::Handle'      => 0,
		'List::MoreUtils' => 0,
		'List::Util'      => 0,
		'Moose'           => 0,
		'Path::Class'     => '0.16',
		'Pod::Usage'      => 0,
		'Readonly'        => 0,
		'Scalar::Util'    => 0,
		'Term::ANSIColor' => 0,
		'Term::Size::Any' => 0,
		'version'         => 0,
		'warnings'        => 0,
	},
	build_requires => {
		'Test::More'       => 0,
		'Test::NoWarnings' => 0,
	},
	add_to_cleanup     => [ 'File-CodeSearch-*' ],
	create_makefile_pl => 'traditional',
	create_license     => 1,
	meta_merge => {
		resources => {
			repository => 'git://github.com/ivanwills/File-CodeSearch.git',
			bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=File-CodeSearch',
		},
	},
);

$builder->create_build_script();
