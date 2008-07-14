package MooseX::Log::Log4perl;

use Moose::Role;
use Log::Log4perl;
use Data::Dumper;

our $VERSION = '0.2';

has 'logger' => (
	is      => 'rw',
	isa     => 'Log::Log4perl::Logger',
	lazy    => 1,
	default => sub { my $self = shift; return Log::Log4perl->get_logger($self) }
);

#sub BUILD {
#	my $pkg = shift;
#
#    return if $pkg eq 'main';
#
#    ( $pkg->can('meta') && ($pkg->meta->isa('Moose::Meta::Class')||$pkg->meta->isa('Moose::Meta::Role')) )
#      || confess "This package can only be used in Moose based classes";
#
#	foreach my $lvl (qw(fatal error warn info debug trace)) {
#		$pkg->meta->add_method("log_$lvl" => sub {
#			my $self = shift;
#			$self->logger->$lvl(@_);
#		});
#    	
#	}
#	print STDERR "Build\n";
#}

sub log {
	my ( $self, $category ) = @_;
	if (defined($category)) {
		return Log::Log4perl->get_logger($category);
	}
	return $self->logger;
}

1;

__END__

=head1 NAME

MooseX::Log::Log4perl - A Logging Role for Moose based on Log::Log4perl

=head1 VERSION

This document describes MooseX::Log::Log4perl version 0.1

=head1 SYNOPSIS

 package MyApp;
 use Moose;
 use Log::Log4perl qw(:easy);
 
 with MooseX::Log::Log4perl;
 
 BEGIN {
   Log::Log4perl->easy_init();
 }
 
 sub foo {
   my ($self) = @_;
   $self->log->debug("started bar");    ### logs with default class catergory "MyApp"
   ...
   $self->log('special')->info('bar');  ### logs with category special
 }

=head1 DESCRIPTION

A logging role building a very lightweight wrapper to L<Log::Log4perl> for use with your L<Moose> classes.
The initialization of the Log4perl instance must be performed prior to logging the first log message.
Otherwise the default initialization will happen, probably not doing the things you expect.

For compatibility the C<logger> attribute can be accessed to use a common interface for application logging.

=head1 ACCESSORS

=head2 logger

The C<logger> attribute holds the L<Log::Log4perl> object that implements all logging methods for the
defined log levels, such as C<debug> or C<error>. As this method is defined also in other logging 
roles/systems like L<MooseX::Log::LogDispatch> this can be thought of as a common logging interface.

  package MyApp::View::JSON;
  
  extends 'MyApp::View';
  with 'MooseX:Log::Log4perl';
  
  sub bar {
    $self->logger->debug("Something could be crappy here");	# logs a debug message
    $self->logger->debug("Something could be crappy here");	# logs a debug message
  }
  

=head2 log

A shorter alias for logger, but also allowing to change the log category
this method call.

 if ($myapp->log->is_debug()) {
     $myapp->log->debug("Woot"); # category is class myapp
 }
 $myapp->log("TempCat")->info("Foobar"); # category TempCat
 $myapp->log->info("Grumble"); # category class again myapp

=head1 SEE ALSO

L<Log::Log4perl>, L<Moose>, L<MooseX::LogDispatch>

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-moosex-log4perl@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

Or come bother us in C<#moose> on C<irc.perl.org>.

=head1 AUTHOR

Roland Lammel C<< <lammel@cpan.org> >>

Inspired by the work by Chris Prather C<< <perigrin@cpan.org> >> and Ash
Berlin C<< <ash@cpan.org> >> on L<MooseX::LogDispatch>

Thanks to Michael Schilli C<< <m@perlmeister.com> >> for L<Log::Log4perl> and suggestions in the interface.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Roland Lammel C<< <lammel@cpan.org> >>. Some rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

