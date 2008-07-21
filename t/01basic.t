#perl

use strict;
use warnings;

use IO::Scalar;
use Log::Log4perl;

use Test::More tests => 9;

BEGIN {
my $cfg = <<__ENDCFG__;
log4perl.rootLogger =DEBUG, Console

log4perl.appender.Console        = Log::Log4perl::Appender::Screen
log4perl.appender.Console.stderr = 1
log4perl.appender.Console.layout = Log::Log4perl::Layout::PatternLayout
log4perl.appender.Console.layout.ConversionPattern = %p [%c] %m%n
__ENDCFG__
Log::Log4perl->init(\$cfg);
}

{

	package ConfigLogTest;

	use Moose;
	with 'MooseX::Log::Log4perl';

	has 'foo' => ( is => 'rw', isa => 'Str' );
}

sub test_logger {
	my ($obj) = @_;

	$obj->log->debug('foo');
	$obj->log("SPECIAL")->info('BAZ');
	$obj->log->error('bar');
}

{
	my $obj = new ConfigLogTest;

	isa_ok( $obj, 'ConfigLogTest' );
	ok( $obj->can('log'),    "Role method log exists" );
	ok( $obj->can('logger'), "Role method logger exists" );
	ok( !$obj->can('log_error'), "Interface not poluted with easy method log_error" );
	ok( !$obj->can('debug'), "Interface not poluted with direct debug method" );

	my $logger = $obj->logger;
	isa_ok( $obj->logger, 'Log::Log4perl::Logger' );
	is( $obj->can('debug'), undef, "Object not poluted" );
	is( $obj->can('error'), undef, "Object not poluted" );

	tie *STDERR, 'IO::Scalar', \my $err;
	local $SIG{__DIE__} = sub { untie *STDERR; die @_ };

	test_logger( $obj );
	untie *STDERR;

	# Cleanup log output line-endings
	$err =~ s/\r\n/\n/gm;

	my $expect = <<__ENDLOG__;
DEBUG [ConfigLogTest] foo
INFO [SPECIAL] BAZ
ERROR [ConfigLogTest] bar
__ENDLOG__

	is( $err, $expect, "Log messages are formated as expected to stderr" );

}
