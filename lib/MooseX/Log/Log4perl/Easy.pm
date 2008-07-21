package MooseX::Log::Log4perl::Easy;

use Moose::Role;

with 'MooseX::Log::Log4perl';

our $VERSION = '0.31';

sub log_fatal {	my $self = shift; $self->logger->fatal(@_); }
sub log_error {	my $self = shift; $self->logger->error(@_); }
sub log_warn  {	my $self = shift; $self->logger->warn(@_); }
sub log_info  {	my $self = shift; $self->logger->info(@_); }
sub log_debug {	my $self = shift; $self->logger->debug(@_); }
sub log_trace {	my $self = shift; $self->logger->trace(@_); }

1;

__END__

=head1 NAME

MooseX::Log::Log4perl::Easy - A Logging Role with easy interface for Moose based on L<MooseX::Log::Log4perl>

=head1 VERSION

This document describes MooseX::Log::Log4perl::Easy version 0.31

=head1 SYNOPSIS

 package MyApp;
 use Moose;
 use Log::Log4perl qw(:easy);

 with 'MooseX::Log::Log4perl::Easy';

 BEGIN {
 	Log::Log4perl->easy_init();
 }

 sub foo {
   my ($self) = @_;
   $self->log_debug("started bar");    ### logs with default class catergory "MyApp"
   $self->log_info('bar');  ### logs an info message
   $self->log('AlsoPossible')->fatal("croak"); ### log
 }

=head1 DESCRIPTION

The Easy logging role based on the L<MooseX::Log::Log4perl> logging role for Moose directly adds the
logmethods for all available levels to your clas instance. Hence it is possible to use

  $self->log_info("blabla");

without having to access a seperate log attribute as in MooseX::Log::Log4perl;

=head1 ACCESSORS

=head2 logger

See L<MooseX::Log::Log4perl>

=head2 log

See L<MooseX::Log::Log4perl>

=head2 log_fatal ($msg)

Logs a fatal message $msg using the logger attribute. Same as calling

  $self->logger->fatal($msg)

=head2 log_error ($msg)

Logs an error message using the logger attribute. Same as calling

  $self->logger->error($msg)

=head2 log_warn ($msg)

Logs a warn message using the logger attribute. Same as calling

  $self->logger->warn($msg)

=head2 log_info ($msg)

Logs an info message using the logger attribute. Same as calling

  $self->logger->info($msg)

=head2 log_debug ($msg)

Logs a debug message using the logger attribute. Same as calling

  $self->logger->debug($msg)

=head2 log_trace ($msg)

Logs a trace message using the logger attribute. Same as calling

  $self->logger->trace($msg)

=head1 SEE ALSO

L<MooseX::Log::Log4perl>, L<Log::Log4perl>, L<Moose>

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-moosex-log4perl@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

Or come bother us in C<#moose> on C<irc.perl.org>.

=head1 AUTHOR

Roland Lammel C<< <lammel@cpan.org> >>

Inspired by suggestions by Michael Schilli C<< <m@perlmeister.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Roland Lammel C<< <lammel@cpan.org> >>. Some rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

