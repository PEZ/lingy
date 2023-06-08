use strict; use warnings;
package Lingy::Atom;

use Lingy::ScalarClass;
use base 'Lingy::ScalarClass';

sub new {
    bless [$_[1] // die], $_[0];
}

1;
