#perl

use strict;
use warnings;

use IO::Scalar;
# use IO::File;
use Log::Log4perl;

use Test::More tests => 7;

BEGIN {
my $cfg = <<__ENDCFG__;
log4perl.rootLogger =DEBUG, Console

log4perl.appender.Console        = Log::Log4perl::Appender::Screen
log4perl.appender.Console.stderr = 1
log4perl.appender.Console.layout = Log::Log4perl::Layout::PatternLayout
log4perl.appender.Console.layout.ConversionPattern = %p [%c] %m%n
# log4perl.appender.Console.layout.ConversionPattern = %d{ISO8601} %p [%c] %m%n
# log4perl.appender.Console.layout = Log::Log4perl::Layout::SimpleLayout
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

	my $logger = $obj->logger;
	isa_ok( $obj->logger, 'Log::Log4perl::Logger' );
	is( $obj->can('debug'), undef, "Object not poluted" );
	is( $obj->can('error'), undef, "Object not poluted" );

	tie *STDERR, 'IO::Scalar', \my $err;
	local $SIG{__DIE__} = sub { untie *STDERR; die @_ };

	test_logger( $obj );
	untie *STDERR;

	# Remove dates from front of lines
	# $err =~ s/^\d{4}-\d\d-\d\d\s+\d\d:\d\d:\d\d(,\d{3})? //gm;
	$err =~ s/(ConfigLogTest)=HASH\([^\)]+\)/$1/gm;
	$err =~ s/\r\n/\n/gm;

	my $expect = <<__ENDLOG__;
DEBUG [ConfigLogTest] foo
INFO [SPECIAL] BAZ
ERROR [ConfigLogTest] bar
__ENDLOG__

#	my $file = IO::File->new(">t/log.err");
#	$file->print("$err\n") && diag("Wrote log.err");
#	$file->close();
#	$file = IO::File->new(">t/log.exp");
#	$file->print("$expect\n") && diag("Wrote log.exp");
#	$file->close();

	is( $err, $expect, "Log messages are formated as expected to stderr" );

}
