
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601",
    "Test::More" => "0.96"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Format envelope result",
  "dist_author" => [
    "Steven Haryanto <stevenharyanto\@gmail.com>"
  ],
  "dist_name" => "Perinci-Result-Format",
  "dist_version" => "0.31",
  "license" => "perl",
  "module_name" => "Perinci::Result::Format",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Data::Clean::JSON" => 0,
    "Data::Format::Pretty" => 0,
    "Data::Format::Pretty::Console" => "0.12",
    "Data::Format::Pretty::JSON" => "0.03",
    "Data::Format::Pretty::YAML" => "0.02",
    "Rinci" => "v1.1.22",
    "perl" => "5.010001"
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
