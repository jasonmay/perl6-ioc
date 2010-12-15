class IoC::Container {
    has %!services = ();

    method add-service($name, $service) {
        if $service.^can('container') {
            $service.container = self;
        }
        $service.name = $name;
        %!services{$name} = $service;
    }

    method fetch($service-name) {
        return %!services{$service-name};
    }
};
