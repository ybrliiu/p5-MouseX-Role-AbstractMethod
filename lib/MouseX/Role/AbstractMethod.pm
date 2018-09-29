package MouseX::Role::AbstractMethod;

use Mouse::Exporter; # enables strict and warnings
use version; our $VERSION = version->declare('v0.01');

use Carp         ();
use Scalar::Util ();

use Mouse ();

use Data::Validator;
use Mouse::Util::TypeConstraints;
 
Mouse::Exporter->setup_import_methods(
    as_is => [qw( abstract )],
);

sub abstract {
    my $meta = Mouse::Meta::Role->initialize(scalar caller);
    my $name = shift;

    $meta->throw_error(q{Usage: abstract 'method' => ( key => value, ... )})
        if @_ % 2; # odd number of arguments

    my %args = @_;
    # $args->{context} //= 'Scalar';

    for my $name (ref $name eq 'ARRAY' ? @{$name} : $name) {
        
        $meta->add_required_methods($name);

        my $type = do {
            if ( exists $args{isa} ) {
                Mouse::Util::TypeConstraints::find_or_create_isa_type_constraint($args{isa});
            }
            elsif ( exists $args{does} ) {
                Mouse::Util::TypeConstraints::find_or_create_does_type_constraint($args{does});
            }
            else {
                Mouse::Util::TypeConstraints::find_or_create_isa_type_constraint('Any');
            }
        };

        my $args_and_return_type_checker = do {
            if ( exists $args{args} ) {
                my $v = Data::Validator->new(%{ $args{args} })->with('Method');
                sub {
                    my $orig = shift;
                    my ($self, $checked_args) = $v->validate(@_);
                    my $return_value = $self->$orig($checked_args);
                    unless ( $type->check($return_value) ) {
                      $meta->throw_error(qq{Mismatch return type : @{[ $meta->name ]}->${name} required '@{[ $type->name ]}'});
                    }
                    $return_value;
                };
            }
            else {
                sub {
                    my ($orig, $self) = @_;
                    my $return_value = $self->$orig();
                    unless ( $type->check($return_value) ) {
                      $meta->throw_error(qq{Mismatch return type : @{[ $meta->name ]}->${name} required '@{[ $type->name ]}'});
                    }
                    $return_value;
                };
            }
        };


        # スタックトレースでどこでエラーが起きているかわかりやすくするため, 名前をつける
        my $checker_method_name = "__MOUSEX_ROLE_ABSTRACT_METHOD__check_${name}_args_and_return_type";
        $meta->add_method($checker_method_name => $args_and_return_type_checker);
        $meta->add_around_method_modifier($name => $args_and_return_type_checker);
    }

    return;
}

 
1;
 
__END__

=encoding utf-8

=head1 NAME

MouseX::Role::AbstractMethod - It's new $module

=head1 SYNOPSIS

    use MouseX::Role::AbstractMethod;

    abstract some_mtehod => (
        isa  => 'Type',
        args => +{
            arg1 => +{ isa => 'Int' },
            arg2 => +{ isa => 'Bool' },
        },
    );

=head1 DESCRIPTION

MouseX::Role::AbstractMethod is ...

=head1 LICENSE

Copyright (C) mp0liiu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

mp0liiu E<lt>raian@reeshome.orgE<gt>

=cut

