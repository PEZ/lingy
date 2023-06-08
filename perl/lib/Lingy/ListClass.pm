use strict; use warnings;
package Lingy::ListClass;

use Lingy::Class;
use base 'Lingy::Class';

sub new {
    my ($class, $list) = @_;
    bless $list, $class;
}

sub clone { ref($_[0])->new([@{$_[0]}]) }

1;
