role IoC::Service {
    has Str $.name is rw;
    has Str $!lifecycle;

    # for singletons
    has Any $!instance;
};
