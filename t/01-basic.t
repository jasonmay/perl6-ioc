BEGIN { @*INC.push('lib') };

use IoC::Container;
use IoC::ConstructorInjection;
use IoC::BlockInjection;
use IoC::Literal;
use Test;

plan 5;

my $c = IoC::Container.new();

class Bar {};
class Foo { has Bar $.bar; };

$c.add-service(
    'foo', IoC::ConstructorInjection.new(
        :class('Foo'),
        :lifecycle('Singleton'),
        :dependencies({
            'bar' => 'bar',
        }),
    )
);

$c.add-service(
    'bar', IoC::BlockInjection.new(
        :class('Bar'),
        :lifecycle('Singleton'),
        :block(sub {
            return Bar.new;
        }),
    )
);

$c.add-service(
    'baz', IoC::Literal.new(
        :lifecycle('Singleton'),
        :value('My name is Jason'),
    )
);



ok($c.fetch('foo').get);
ok($c.fetch('bar').get);

ok($c.fetch('foo').get.bar);

is($c.fetch('foo').get.bar, $c.fetch('bar').get);

is($c.fetch('baz').get, 'My name is Jason');
