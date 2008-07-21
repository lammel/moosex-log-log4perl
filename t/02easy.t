#perl

use strict;
use warnings;

use IO::Scalar;
use Log::Log4perl;

use Test::More tests => 10;

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
	with 'MooseX::Log::Log4perl::Easy';

	has 'foo' => ( is => 'rw', isa => 'Str' );
}

sub test_logger {
	my ($obj) = @_;

	$obj->log->debug('foo');
	$obj->log("SPECIAL")->info('BAZ');
	$obj->log->error('bar');
	$obj->log_fatal('brains');
}

{
	my $obj = new ConfigLogTest;

	isa_ok( $obj, 'ConfigLogTest' );

	### Test the interface
	ok( $obj->can("logger"),    "Role method logger exists" );
	ok( $obj->can("log"),    "Role method log exists" );
	foreach my $lvl (qw(fatal error warn info debug trace)) {
		ok( $obj->can("log_$lvl"),    "Role method log_$lvl exists" );
	}

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
FATAL [ConfigLogTest] brains
__ENDLOG__

	is( $err, $expect, "Log messages are formated as expected to stderr" );

}
