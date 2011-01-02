use IoC::Service;
class IoC::ConstructorInjection does IoC::Service {
    has Str $.class;
    has     %.dependencies = ();
    has     %.parameters;
    has     $.container is rw;

    method get {
        if ($!lifecycle eq 'Singleton') {
            return (
                $!instance ||= self.build-instance();
            );
        }

        return self.build-instance();
    }

    method build-instance {
        my %params;

        for %!dependencies.pairs -> $pair {
            %params{$pair.key} = $!container.fetch($pair.value).get();
        };

        return eval("{$!class}.new(|%params)");
    }
};

