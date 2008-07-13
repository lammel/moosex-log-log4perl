use inc::Module::Install '0.72';

name 'MooseX-Log-Log4perl';
all_from 'lib/MooseX/Log/Log4perl.pm';

build_requires 'IO::Scalar';
build_requires 'Test::More';

requires 'Moose';
requires 'Log::Log4perl';

auto_install;
WriteAll;
