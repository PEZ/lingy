use strict; use warnings;
package Lingy::Lang::Number;

use base 'Lingy::Lang::ScalarClass';
use Lingy::Common;

use overload
    '""' => sub { ${$_[0]} },
    '+' => \&add,
    '-' => \&subtract,
    '*' => \&multiply,
    '/' => \&divide,
    '==' => \&equal_to,
    '>' => \&greater_than,
    '>=' => \&greater_equal,
    '<' => \&less_than,
    '<=' => \&less_equal,
    '%' => \&modulo,
    ;

sub greater_than {
    my ($x, $y) = @_;
    $x = ref($x) ? $$x : $x;
    $y = ref($y) ? $$y : $y;
    boolean($x > $y);
}

sub greater_equal {
    my ($x, $y) = @_;
    $x = ref($x) ? $$x : $x;
    $y = ref($y) ? $$y : $y;
    boolean($x >= $y);
}

sub less_than {
    my ($x, $y) = @_;
    $x = ref($x) ? $$x : $x;
    $y = ref($y) ? $$y : $y;
    boolean($x < $y);
}

sub less_equal {
    my ($x, $y) = @_;
    $x = ref($x) ? $$x : $x;
    $y = ref($y) ? $$y : $y;
    boolean($x <= $y);
}

sub add {
    my ($x, $y) = @_;
    my $class = ref($x);
    $x = ref($x) ? $$x : $x;
    $y = ref($y) ? $$y : $y;
    $class->new($x + $y);
}

sub subtract {
    my ($x, $y) = @_;
    my $class = ref($x);
    $x = ref($x) ? $$x : $x;
    $y = ref($y) ? $$y : $y;
    $class->new($x - $y);
}

sub multiply {
    my ($x, $y) = @_;
    my $class = ref($x);
    $x = ref($x) ? $$x : $x;
    $y = ref($y) ? $$y : $y;
    $class->new($x * $y);
}

sub divide {
    my ($x, $y) = @_;
    my $class = ref($x);
    $x = ref($x) ? $$x : $x;
    $y = ref($y) ? $$y : $y;
    $class->new($x / $y);
}

sub modulo {
    my ($x, $y) = @_;
    my $class = ref($x);
    $x = ref($x) ? $$x : $x;
    $y = ref($y) ? $$y : $y;
    $class->new($x % $y);
}

1;
