use Test::More;
use MouseX::Role::AbstractMethod;

package TestRole {

  use Mouse::Role;
  use MouseX::Role::AbstractMethod;

  abstract method => (
    isa  => 'Int',
    args => {
      arg1 => { isa => 'Int' },
      arg2 => { isa => 'Int' },
    },
  );

}

package SomeClass {

  use Mouse;

  with 'TestRole';

  sub method {}

  __PACKAGE__->meta->make_immutable;

}

my $obj = SomeClass->new;
$obj->method(arg1 => 10, arg2 => 20);

ok 1;

done_testing;
