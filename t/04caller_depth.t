use strict;
use warnings;

use Test::More;
use IO::Scalar;
use Log::Log4perl;

# local, it's not what you think:
#   perl -E 'sub rofl { say $a }; sub lol { local $a += 1; rofl  }; our $a = 12 ; lol() '
{
	Log::Log4perl->init( \q{
log4perl.rootLogger = TRACE, Test

log4perl.appender.Test        = Log::Log4perl::Appender::String
log4perl.appender.Test.stderr = 1
log4perl.appender.Test.layout = Log::Log4perl::Layout::PatternLayout
log4perl.appender.Test.layout.ConversionPattern = calling=<%l> caller_line=<%L> - %m
});


    my $log = I::Log->new;
    $log->log_should_be_invisible('called from main');

    my $messages= $Log::Log4perl::Logger::APPENDER_BY_NAME{Test}->string;
    unlike( $messages, qr{I::Log::log_should_be_invisible}, "We shouldn't see log_should_be_invisible in the log entry") or diag "unexpected log: $messages";
    like($messages, qr{called from main}, "our message made it through");
    like($messages, qr{\QYou shouldn't see me as the caller!}, "log_should_be_invisible's message should be in the log");
}


BEGIN {
# line 1 "I/Log.pm"
    package I::Log {
        use Moo;
        with 'MooseX::Log::Log4perl::Easy';

        sub log_should_be_invisible {
            my $self = shift;
            local $Log::Log4perl::caller_depth
                = $Log::Log4perl::caller_depth + 1;

            $self->log_info("You shouldn't see me as the caller!: @_")
        }

    }
}

done_testing;
