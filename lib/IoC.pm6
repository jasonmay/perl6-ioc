module IoC;

use IoC::Container;
use IoC::ConstructorInjection;
use IoC::BlockInjection;

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
    my %params = ('name' => $pair.key, $pair.value.pairs);


    my $service-class;
    if %params<block> {
        $service-class = 'IoC::BlockInjection';
    }
    elsif %params<class> {
        $service-class = 'IoC::ConstructorInjection';
    }
    else {
        warn "Service {$pair.key} needs more parameters";
        return;
    }

    my $service = eval("{$service-class}.new(|%params)");
    #my $service = $service-class.new(|%params);

    %containers{$container-name}.add-service($pair.key, $service);
}
