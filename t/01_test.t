use Test::More;
use Test::Exception;
use MouseX::Role::AbstractMethod;

package TestRole {

  use Mouse::Role;
  use MouseX::Role::AbstractMethod;

  abstract method => (
    isa  => 'Int',
    args => +{
      arg1 => 'Int',
      arg2 => 'Int',
    },
  );

  abstract sum => (
    isa  => 'Int',
    args => +{
      num1 => 'Int',
      num2 => 'Int',
    },
  );

}

package SomeClass {

  use Mouse;

  with 'TestRole';

  sub method {
    my ($self, $args) = @_;
    my ($arg1, $arg2) = @$args{qw( arg1 arg2 )};
    $arg1 + $arg2;
  }

  sub sum {
    my ($self, $args) = @_;
    my ($num1, $num2) = @$args{qw( num1 num2 )};
    "$num1 + $num2";
  }

  __PACKAGE__->meta->make_immutable;

}

my $obj = SomeClass->new;
lives_ok { $obj->method(arg1 => 10, arg2 => 20) };
dies_ok { $obj->method(arg1 => 'string', arg2 => []) };
diag $@;
dies_ok { $obj->sum(num1 => 1, num2 => 2) };
diag $@;

done_testing;
