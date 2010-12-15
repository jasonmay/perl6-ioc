use IoC::Service;
class IoC::BlockInjection does IoC::Service {
    has Sub $.block;
    has $.class;

    method get {
        if ($!lifecycle eq 'Singleton') {
            return (
                $!instance ||= $!block.();
            );
        }

        return $!block.();
    }
};
