use inc::Module::Install '0.85';

name 'MooseX-Log-Log4perl';
all_from 'lib/MooseX/Log/Log4perl.pm';

build_requires 'IO::Scalar';
build_requires 'Test::More';
build_requires 'Moose' => '0.65';

requires 'Any::Moose' => '0.12';
requires 'Log::Log4perl' => '1.13';

recommends 'Moose' => '0.65';

license 'perl';

auto_install;
WriteAll;
