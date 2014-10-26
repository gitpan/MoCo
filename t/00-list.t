#!perl -T
use strict;
use warnings;
use File::Spec;
use lib File::Spec->catdir('lib');
use lib File::Spec->catdir('t', 'lib');

ThisTest->runtests;

# ThisTest
package ThisTest;
use base qw/Test::Class/;
use Test::More;
use MoCo::List;

sub use_test : Tests {
    use_ok 'MoCo::List';
}

sub new_test : Tests {
    my $array_ref = [1,2];
    my $list = MoCo::List->new($array_ref);
    ok $list;
    isa_ok $list, 'MoCo::List';
    isa_ok $list, 'ARRAY';
    is $list->size, 2;
    is $list->first, 1;
    is $list->last, 2;
}

1;
