module IoC;

use IoC::Container;
use IoC::ConstructorInjection;
use IoC::BlockInjection;
use IoC::Literal;

my %containers;
my $container-name;

sub container($pair) is export {
    %containers{$pair.key} = IoC::Container.new(
        :name($pair.key),
    );

    $container-name = $pair.key;
    
    unless $pair.value.^isa('Block') {
        die "Second param must be invocable";
    }

    $pair.value.();

    return %containers{$container-name};
}

sub contains(Block $sub) is export { return $sub }

sub service($pair) is export {
    my %params = ('name' => $pair.key);
    if $pair.value.^isa('Str') {
        %params<value> = $pair.value;
    }
    else {
        %params = (%params, $pair.value.pairs);
    }

    my $service-class;
    if %params<block> {
        $service-class = 'IoC::BlockInjection';
    }
    elsif %params<class> {
        $service-class = 'IoC::ConstructorInjection';
    }
    elsif %params<value> {
        $service-class = 'IoC::Literal';
    }
    else {
        warn "Service {$pair.key} needs more parameters";
        return;
    }

    my $service = eval("{$service-class}.new(|%params)");
    #my $service = $service-class.new(|%params);

    %containers{$container-name}.add-service($pair.key, $service);
}


=head1 NAME

IoC - Wire your application components together using inversion of control

=head1 SYNOPSIS

  use IoC;

  my $c = container 'myapp' => contains {

      service 'logfile' => 'logfile.txt';

      service 'logger' => {
          'class'        => 'MyLogger',
          'lifecycle'    => 'Singleton',
          'dependencies' => {'logfile' => 'logfile'},
      };

      service 'storage' => {
          'lifecycle' => 'Singleton',
          'block'     => sub {
              ...
              return MyStorage.new();
          },
      };

      service 'app' => {
          'class'        => 'MyApp',
          'lifecycle'    => 'Signleton',
          'dependencies' => {
              'logger'  => 'logger',
              'storage' => 'storage',
          },
      };

  };

  my $app = $c.resolve(service => 'app');
  $app.run();

=head1 DESCRIPTION

IoC is a port of stevan++'s Perl 5 module Bread::Board

=head1 EXPORTED FUNCTIONS

=over 4

=item B<container>

Creates a new L<IoC::Container> object. In the block you create your services.

=item B<service>

Adds services to your container, bringing your components together. See
C<IoC::Service> for more information on this.

=back

=over 4

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or post an issue
to http://github.com/jasonmay/perl6-ioc/

=head1 REFERENCE

=over 4

=item L<IoC::Container> - Container of all your application components

=item L<IoC::Service> - Serice representing a component in your application

=back

=head1 ACKNOWLEDGEMENTS

=over 4

=item Thanks to Stevan Little who is the original author of Perl 5's Bread::Board

=back

=head1 AUTHOR

Jason May, E<lt>jason.a.may@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
