#perl

use strict;
use warnings;

use Benchmark qw(:all :hireswallclock);
use Log::Log4perl;
use vars qw($tmplogfile);

use Test::More tests => 6;

END {
	### Remove tmpfile if exists
	unlink($tmplogfile) if (-f $tmplogfile);
}

{	
	### Define a custom Log4perl appender that simply does not log anything
	### as we only need to check on call performance not actuall performance
	### of the appender
	package Log::Log4perl::Appender::TestNirvana;
	use base qw( Log::Log4perl::Appender::TestBuffer );
	sub log {}
}

{
	package BenchMooseXLogLog4perl;

	use Moose;
	with 'MooseX::Log::Log4perl';
	
	sub testlog { shift->log->info("Just a test for logging"); }
	sub testlogger { shift->logger->info("Just a test for logging"); }
	__PACKAGE__->meta->make_immutable;
}

{
	package BenchLogLog4perl;

	use Log::Log4perl;
	use vars qw($log);
	
	BEGIN { $log = Log::Log4perl->get_logger(__PACKAGE__); }
	
	sub new { bless({log=>$log},__PACKAGE__); }
	sub log { return shift->{log}; };

	sub testlogmethod { shift->log->info("Just a test for logging"); }
	sub testlogdirect { $log->info("Just a test for logging"); }
}

###
### Tests start here
###
{
	$tmplogfile = 'mxll4p_benchtest.log';
	my $cfg = <<__ENDCFG__;
log4perl.rootLogger = INFO, Nirvana
log4perl.appender.Nirvana = Log::Log4perl::Appender::TestNirvana
log4perl.appender.Nirvana.layout = Log::Log4perl::Layout::PatternLayout
log4perl.appender.Nirvana.layout.ConversionPattern = %p [%c] %m%n
__ENDCFG__
	Log::Log4perl->init(\$cfg);
	
	my $mxl = new BenchMooseXLogLog4perl();
	my $llp = new BenchLogLog4perl();
	
	isa_ok( $mxl, 'BenchMooseXLogLog4perl', 'Bench instance for MooseX::Log::Log4perl');
	isa_ok( $llp, 'BenchLogLog4perl', 'Bench instance for Log::Log4perl');

	# my $bllp1 = Benchmark::timeit(100000, sub { $llp->testlog() });
	# diag(timestr($bllp1));
	# my $bllp2 = Benchmark::timeit(100000, sub { $llp->testlogobj() });
	# diag(timestr($bllp2));
	# my $bmxl1 = Benchmark::timeit(100000, sub { $mxl->testlog() });
	# diag(timestr($bmxl1));
	# my $bmxl2 = Benchmark::timeit(100000, sub { $mxl->testlogger() });
	# diag(timestr($bmxl2));	
	### We expect some bsaic performance of approx. 10% to Log4perl directly
	my $result = cmpthese(-10, {
		'Log4perl direct' => sub { $llp->testlogdirect() },
		'Log4perl method' => sub { $llp->testlogmethod() },
		'MooseX-L4p logger' => sub { $mxl->testlogger() },
		'MooseX-L4p log' => sub { $mxl->testlog() },
	});
	### Compare the rates now
	my %bench = ();
	foreach (@{$result}) {
		my @row = @{$_};
		my $rate = $row[1]; $rate =~ s?/s$??;
		$bench{$row[0]} = $rate;
		# diag($rate);
	}
	my ($rate_logger, $rate_log);
	$rate_logger = 100 * $bench{'MooseX-L4p logger'} / $bench{'Log4perl direct'};
	ok($rate_logger > 96, sprintf("Call rate of ->logger must be above 96%% " .
		"(%i / %i = %.2f %%) to Log4perl direct", $bench{'MooseX-L4p logger'}, $bench{'Log4perl direct'}, $rate_logger));
	$rate_log = 100 * $bench{'MooseX-L4p log'} / $bench{'Log4perl direct'};
	ok($rate_log > 95, sprintf("Call rate of ->log must be above 95%% " .
		"(%i / %i = %.2f %%) to Log4perl direct", $bench{'MooseX-L4p logger'}, $bench{'Log4perl direct'}, $rate_log));

	$rate_logger = 100 * $bench{'MooseX-L4p logger'} / $bench{'Log4perl method'};
	ok($rate_logger > 98, sprintf("Call rate of ->logger must be above 98%% " .
		"(%i / %i = %.2f %%) to Log4perl via method", $bench{'MooseX-L4p logger'}, $bench{'Log4perl method'}, $rate_logger));
	$rate_log = 100 * $bench{'MooseX-L4p log'} / $bench{'Log4perl method'};
	ok($rate_log > 97, sprintf("Call rate of ->log must be above 97%% " .
		"(%i / %i = %.2f %%) to Log4perl via method", $bench{'MooseX-L4p logger'}, $bench{'Log4perl method'}, $rate_log));

}
