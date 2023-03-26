use strict; use warnings;
package Lingy::Types;

use Exporter 'import';

our @EXPORT = qw<
    atom
    boolean
    false
    function
    hash_map
    keyword
    list
    macro
    nil
    number
    string
    symbol
    true
    vector

    PPP
    WWW
    XXX
    YYY
    ZZZ

    RT
    err
    fn
>;

sub atom     { 'atom'    ->new(@_) }
sub boolean  { 'boolean' ->new(@_) }
sub function { 'function'->new(@_) }
sub keyword  { 'keyword' ->new(@_) }
sub hash_map { 'hash_map'->new(@_) }
sub list     { 'list'    ->new(@_) }
sub macro    { 'macro'   ->new(@_) }
sub number   { 'number'  ->new(@_) }
sub string   { 'string'  ->new(@_) }
sub symbol   { 'symbol'  ->new(@_) }
sub vector   { 'vector'  ->new(@_) }

sub WWW { require XXX; goto &XXX::WWW }
sub XXX { require XXX; goto &XXX::XXX }
sub YYY { require XXX; goto &XXX::YYY }
sub ZZZ { require XXX; goto &XXX::ZZZ }
sub PPP { require Lingy::Printer; XXX(Lingy::Printer::pr_str(@_)) }

sub RT { $Lingy::Runtime::rt }

sub err {
    my $msg = shift;
    die "Error:" .
        ($msg =~ /\n./ ? "\n" : ' ') .
        $msg .
        "\n";
}

sub fn {
    my $functions = {@_};
    sub {
        my $arity = @_;
        my $function =
            $functions->{$arity} ||
            $functions->{'*'}
                or err "Wrong number of args ($arity) passed to function";
        $function->(@_);
    }
}


#------------------------------------------------------------------------------
# Base Classes:
#------------------------------------------------------------------------------
package Lingy::List;

sub new {
    my ($class, $list) = @_;
    bless $list, $class;
}

sub clone { ref($_[0])->new([@{$_[0]}]) }

#------------------------------------------------------------------------------
package Lingy::Map;

sub new { die }

#------------------------------------------------------------------------------
package Lingy::Scalar;

use overload '""' => sub { ${$_[0]} };
use overload cmp => sub { "$_[0]" cmp "$_[1]" };

sub new {
    my ($class, $scalar) = @_;
    bless \$scalar, $class;
}


#------------------------------------------------------------------------------
# Lingy::List types:
#------------------------------------------------------------------------------
package
list;
use base 'Lingy::List';

#------------------------------------------------------------------------------
package
vector;
use base 'Lingy::List';

#------------------------------------------------------------------------------
package
hash_map;
use base 'Lingy::Map';
use Tie::IxHash;
sub err;
*err = \&Lingy::Types::err;

sub new {
    my ($class, $list) = @_;
    for (my $i = 0; $i < @$list; $i += 2) {
        my $key = $list->[$i];
        if (my $type = ref($key)) {
            err "Type '$type' not supported as a hash-map key\n"
                if not($key->isa('Lingy::Scalar')) or $type eq 'symbol';
            $list->[$i] = $type eq 'string' ? qq<"$key> : qq<$key>;
        }
    }
    my %hash;
    my $tie = tie(%hash, 'Tie::IxHash', @$list);
    my $hash = \%hash;
    bless $hash, $class;
}

sub clone {
    hash_map->new([ %{$_[0]} ]);
}

#------------------------------------------------------------------------------
# Lingy::Scalar types:
#------------------------------------------------------------------------------
package
function;

*list = \&Lingy::Types::list;
*symbol = \&Lingy::Types::symbol;
sub err;
*err = \&Lingy::Types::err;

sub new {
    my ($class, $ast, $env) = @_;

    my (undef, @exprs) = @$ast;
    @exprs = (list([@exprs]))
        if ref($exprs[0]) eq 'vector';

    my $functions = [];
    my $variadic = '';

    for my $expr (@exprs) {
        err "fn expr is not a list"
            unless ref($expr) eq 'list';
        my ($sig, @body) = @$expr;
        err "fn signature not a vector"
            unless ref($sig) eq 'vector';
        my $arity = (grep {$$_ eq '&'} @$sig) ? -1 : @$sig;
        if ($arity == -1) {
            $variadic = @$sig - 1;
        } elsif ($variadic) {
            err "Can't have fixed arity function " .
                "with more params than variadic function"
                if @$sig > $variadic;
        }
        @body = (list([ symbol('do'), @body ]))
            if @body > 1;
        if (exists $functions->[$arity+1]) {
            err $arity == -1
                ? "Can't have more than 1 variadic overload"
                : "Can't have 2 overloads with same arity";
        }
        $functions->[$arity+1] = [$sig, @body];
    }

    bless sub {
        my $arity = @_;
        my $function =
            $functions->[$arity+1] ? $functions->[$arity+1] :
            $arity >= (@$functions-1) ? $functions->[0] :
                err "Wrong number of args ($arity) passed to function";
        my ($sig, $ast) = @$function;

        return (
            $ast,
            Lingy::Env->new(
                outer => $env,
                binds => $sig,
                exprs => \@_,
            ),
        );
    }, $class;
}
sub clone {
    my ($fn) = @_;
    bless sub { goto &$fn }, ref($fn);
}

package
macro;
# use base 'function';
sub new {
    my ($class, $function) = @_;
    XXX $function unless ref($function) eq 'function';
    bless sub { goto &$function }, $class;
}


package
atom;
sub new {
    bless [$_[1] // die], $_[0];
}


package
symbol;
use base 'Lingy::Scalar';


package
string;
use base 'Lingy::Scalar';


package
keyword;
use base 'Lingy::Scalar';
sub new {
    my ($class, $scalar) = @_;
    $scalar =~ s/^://;
    $scalar = ":$scalar";
    bless \$scalar, $class;
}



package
nil;
use base 'Lingy::Scalar';

{
    package Lingy::Types;
    my $n;
    BEGIN { $n = 1 }
    use constant nil => bless \$n, 'nil';
}


package
boolean;
use base 'Lingy::Scalar';

{
    package Lingy::Types;
    my ($t, $f);
    BEGIN { ($t, $f) = (1, 0) }
    use constant true => bless \$t, 'boolean';
    use constant false => bless \$f, 'boolean';
}

sub new {
    my ($class, $scalar) = @_;
    my $type = ref($scalar);
    (not $type) ? $scalar ? Lingy::Types::true : Lingy::Types::false :
    $type eq 'nil' ? Lingy::Types::false :
    $type eq 'boolean' ? $scalar :
    Lingy::Types::true;
}


package
number;
use base 'Lingy::Scalar';

sub boolean { boolean->new(@_) }

use overload
    '""' => sub { ${$_[0]} },
    '+' => \&add,
    '-' => \&subtract,
    '*' => \&multiply,
    '/' => \&divide,
    '=' => \&equal_to,
    '>' => \&greater_than,
    '>=' => \&greater_equal,
    '<' => \&less_than,
    '<=' => \&less_equal,
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

1;
