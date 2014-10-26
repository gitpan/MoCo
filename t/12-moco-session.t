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
use MoCo;
use Blog::User;
use Blog::Bookmark;
use Blog::Entry;

sub start_session : Test(setup) {
    MoCo->start_session;
}

sub session : Tests {
    my $s = MoCo->session;
    ok $s;
    isa_ok $s->{changed_objects}, 'ARRAY';
    ok (MoCo->is_in_session);
}

sub end_session : Tests {
    MoCo->end_session;
    ok (!MoCo->session);
    ok (!MoCo->is_in_session);
    MoCo->start_session;
}

sub param : Tests {
    my $u = Blog::User->retrieve(1);
    ok (MoCo->is_in_session);
    my $name = $u->name;
    ok $name;
    $u->name('jkontan');
    is $u->name, 'jkontan';
    isnt $u->name, $name;
    ok ($u->to_be_updated);
    my ($u2) = Blog::User->search(where => {user_id => 1});
    ok $u2;
    is $u2->name, $name;
    isnt $u2->name, $u->name;
    $u->save;
    is $u->name, 'jkontan';
    ok (!$u->to_be_updated);
    my ($u3) = Blog::User->search(where => {user_id => 1});
    is $u3->name, 'jkontan';
}

sub create : Tests {
    my $u = Blog::User->create(
        user_id => 7,
        name => 'lucky7',
    );
    ok $u;
    is $u->user_id, 7;
    is $u->name, 'lucky7';
    my ($u2) = Blog::User->search(where => {user_id =>7});
    ok (!$u2);
    $u->name('lucky lucky 7');
    is $u->name, 'lucky lucky 7';
    my ($u3) = Blog::User->search(where => {user_id =>7});
    ok (!$u3);
    MoCo->end_session;
    MoCo->start_session;
    my ($u4) = Blog::User->search(where => {user_id =>7});
    ok ($u4);
    is $u4->user_id, 7;
    is $u4->name, 'lucky lucky 7';
    my $u5 = Blog::User->retrieve(7);
    is $u5, $u;
}

1;
