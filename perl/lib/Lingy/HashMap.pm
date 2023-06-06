use strict; use warnings;
package Lingy::HashMap;

use Lingy::Common;
use base CLASS;

use Hash::Ordered;

*err = \&Lingy::Common::err;

sub new {
    my ($class, $list) = @_;
    tie my %hash, 'Hash::Ordered';
    for (my $i = 0; $i < @$list; $i += 2) {
        my $key = $class->_get_key($list->[$i]);
        delete $hash{$key} if exists $hash{$key};
        $hash{$key} = $list->[$i + 1];
    }
    bless \%hash, $class;
}

sub clone {
    HASHMAP->new([ %{$_[0]} ]);
}

sub assoc {
    my ($self, $key, $val) = @_;
    my $new = $self->clone;
    $key = $self->_get_key($key);
    $new->{$key} = $val;
    $new;
}

sub _get_key {
    my ($self, $key) = @_;
    my $type = ref($key);
    $type eq '' ? qq<$key> :
    $type eq STRING ? qq<"$key> :
    $type eq SYMBOL ? qq<$key > :
    $type->isa(SCALARTYPE) ? qq<$key> :
    (   # Quoted symbol:
        $type eq LIST and
        ref($key->[0]) eq SYMBOL and
        ${$key->[0]} eq 'quote' and
        ref($key->[1]) eq SYMBOL
    ) ? ${$key->[1]} . ' ' :
    err "Type '$type' not supported as a hash-map key";
}

sub _to_seq {
    my ($map) = @_;
    return nil unless %$map;
    LIST->new([
        map {
            my $val = $map->{$_};
            my $key =
                s/^"// ? STRING->new($_) :
                s/^(\S+) $/$1/ ? SYMBOL->new($_) :
                s/^:// ? KEYWORD->new($_) :
                m/^\d+$/ ? NUMBER->new($_) :
                XXX $_;
            VECTOR->new([$key, $val]);
        } keys %{$_[0]}
    ]);
}

1;
