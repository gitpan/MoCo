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
use Blog::Entry;
use Blog::Bookmark;

sub use_test: Tests {
    use_ok 'MoCo';
    use_ok 'Blog::Class';
    use_ok 'Blog::DataBase';
    use_ok 'Blog::User';
    use_ok 'Blog::Entry';
    use_ok 'Blog::Bookmark';
}

sub new_test : Tests {
    my $o;
    $o = Blog::User->new(name => 'jack');
    ok $o;
    isa_ok $o, 'Blog::User';
    is $o->name, 'jack';
    is (Blog::User->table, 'user');
    my $pk = Blog::User->primary_keys;
    isa_ok $pk, 'ARRAY';
    is $pk->[0], 'user_id';
}

sub has_a : Tests {
    my $has_a = Blog::Bookmark->has_a;
    ok $has_a;
    ok $has_a->{user};
    is $has_a->{user}->{class}, 'Blog::User';
    ok $has_a->{user}->{option};
    is $has_a->{user}->{option}->{key}, 'user_id';
    ok $has_a->{entry};
    is $has_a->{entry}->{class}, 'Blog::Entry';
    ok $has_a->{entry}->{option};
    is $has_a->{entry}->{option}->{key}, 'entry_id';
}

sub has_many : Test(5) {
    my $has_many = Blog::User->has_many;
    ok $has_many;
    ok $has_many->{bookmarks};
    is $has_many->{bookmarks}->{class}, 'Blog::Bookmark';
    ok $has_many->{bookmarks}->{option};
    is $has_many->{bookmarks}->{option}->{key}, 'user_id';
}

sub object_id : Tests {
    is(Blog::User->object_id(1), 'Blog::User-user_id-1');
    is(Blog::User->object_id(user_id => 1), 'Blog::User-user_id-1');
    is(Blog::User->object_id(name => 'jkondo'), 'Blog::User-name-jkondo');
}

sub retrieve : Tests {
    my $u = Blog::User->retrieve(1);
    ok $u;
    is $u->user_id, 1;
    is $u->name, 'jkondo';
}

sub create : Tests {
    my $u = Blog::User->create(
        user_id => 16,
        name => 'jkontan',
    );
    ok $u;
    isa_ok $u, 'Blog::User';
    is $u->user_id, 16;
    is $u->name, 'jkontan';
}

sub delete : Tests {
    my $u = Blog::User->create(
        user_id => 99,
        name => 'dummy',
    );
    ok $u;
    ok $u->delete;
    $u = Blog::User->retrieve(99);
    ok !$u;
    $u = Blog::User->create(
        user_id => 99,
        name => 'dummy',
    );
    ok $u;
    $u = Blog::User->retrieve(99);
    ok(Blog::User->delete($u));
    $u = Blog::User->retrieve(99);
    ok !$u;
}

sub retrieve_by : Tests {
    my $u = Blog::User->retrieve_by_user_id(1);
    ok $u;
    is $u->user_id, 1;
    is $u->name, 'jkondo';
    $u = Blog::User->retrieve_by_name('cinnamon');
    ok $u;
    is $u->user_id, 3;
    is $u->name, 'cinnamon';
    my $b = Blog::Bookmark->retrieve_by_user_id_and_entry_id(1,3);
    ok $b;
    is $b->user_id, 1;
    is $b->entry_id, 3;
}

sub retrieve_by_or_create : Tests {
    my $u = Blog::User->retrieve_by_user_id_or_create(1);
    ok $u;
    is $u->user_id, 1;
    is $u->name, 'jkondo';
    $u = Blog::User->retrieve_by_user_id_or_create(123);
    ok $u;
    is $u->user_id, 123;
    $u = Blog::User->retrieve_by_user_id_and_name_or_create(31, 'keke');
    ok $u;
    is $u->user_id, 31;
    is $u->name, 'keke';
}

sub retrieve_has_a : Test(5) {
    my $p = Blog::Bookmark->retrieve_by_user_id_and_entry_id(1,3);
    ok $p;
    my $u = $p->user;
    ok $u;
    is $u->name, 'jkondo';
    my $e = $p->entry;
    ok $e;
    is $e->title, 'reikon-1';
}

sub search : Tests {
    my ($u) = Blog::User->search(where => {user_id => 1});
    ok $u;
    isa_ok $u, 'Blog::User';
    is $u->user_id, 1;
    ($u) = Blog::User->search(
        where => ['name = ?', 'jkondo'],
    );
    ok $u;
    is $u->name, 'jkondo';
    ($u) = Blog::User->search(
        where => ['name = :name', name => 'cinnamon'],
    );
    ok $u;
    is $u->name, 'cinnamon';
}

sub retrieve_all : Tests {
    my $b1 = Blog::Bookmark->retrieve_all(
        where => {user_id => 1},
        order => 'entry_id',
    );
    ok $b1;
    isa_ok $b1, 'MoCo::List';
    for (@$b1) {
        isa_ok $_, 'Blog::Bookmark';
        is $_->user_id, 1;
        is $_->entry_id + 0, $_->entry_id;
    }
    my $b2 = Blog::Bookmark->retrieve_all(
        where => {user_id => 1},
        order => 'entry_id',
        limit => 1,
    );
    ok $b2;
    is $b2->[0], $b1->[0];
    my $b3 = Blog::Bookmark->retrieve_all(
        where => {user_id => 1},
        order => 'entry_id',
        offset => 1,
        limit => 1,
    );
    ok $b3;
    is $b3->[0], $b1->[1];
}

sub retrieve_has_many : Tests {
    my $u = Blog::User->retrieve(1);
    ok $u;
    my $bs = $u->bookmarks;
    ok $bs;
    isa_ok $bs, 'MoCo::List';
    ok $bs->size;
}

sub cache_has_a : Tests {
    my $u1 = Blog::User->retrieve(1);
    my $u2 = Blog::User->retrieve(1);
    is $u2, $u1;
    my $u3 = Blog::User->retrieve_by_name('jkondo');
    is $u3, $u1;
}

sub cache_has_many : Tests {
    my $u = Blog::User->retrieve(1);
    is $u->entries, $u->entries;
}

sub flush_objects : Tests {
    my $u = Blog::User->retrieve(2);
    ok $u;
    my $bs = $u->bookmarks;
    ok $bs;
    isa_ok $bs, 'MoCo::List';
    my $bs2 = $u->bookmarks;
    is $bs2, $bs;
    my $e = Blog::Entry->retrieve(3);
    ok $e;
    my $bs3 = $e->bookmarks;
    ok $bs3;
    isa_ok $bs3, 'MoCo::List';
    my $bs4 = $e->bookmarks;
    is $bs4, $bs3;
    isnt $bs4, $bs;
    my $b = Blog::Bookmark->create(
        user_id => 2,
        entry_id => 3,
    );
    my $bs5 = $u->bookmarks;
    isnt $bs5, $bs;
    is $bs5->size, $bs->size + 1;
    my $bs6 = $e->bookmarks;
    isnt $bs6, $bs3;
    is $bs6->size, $bs3->size + 1;
}

sub list_methods : Tests {
    my $es = Blog::User->retrieve(1)->entries;
    my $e = $es->pop;
    ok $e;
    isa_ok $e, 'Blog::Entry';
    ok $e->entry_id;
    ok $e->title;
}

sub map_attr : Tests {
    my $user = Blog::User->retrieve(1);
    $user->entries;
    $user->flush('entries');
    my $bs = $user->bookmarks;
    ok $bs;
    isa_ok $bs, 'MoCo::List';
    my $es = $bs->map_entry;
    ok $es;
    isa_ok $es, 'ARRAY';
    is $bs->size, $es->size;
    my $e = $es->[0];
    ok $e;
    isa_ok $e, 'Blog::Entry';
    my @bss = Blog::Bookmark->search(where => {user_id => 1});
    is scalar @bss, $bs->size;
    my @entry_ids = $bs->map_entry_id;
    ok @entry_ids;
    for (@entry_ids) {
        is $_ + 0, $_;
    }
}

sub cache_status : Test(4) {
    my $cs = $MoCo::cache_status;
    my %pre = %$cs;
    my $u = Blog::User->retrieve(1);
    is $cs->{retrieve_count}, $pre{retrieve_count} + 1;
    %pre = %$cs;
    $u = Blog::User->retrieve(1);
    is $cs->{retrieve_cache_count}, $pre{retrieve_cache_count} + 1;
    %pre = %$cs;
    $u->flush('entries');
    $u->entries;
    is $cs->{has_many_count}, $pre{has_many_count} + 1;
    %pre = %$cs;
    $u->entries;
    is $cs->{has_many_cache_count}, $pre{has_many_cache_count} + 1;
}

sub has_many_cache_slice : Tests {
    my $cs = $MoCo::cache_status;
    my $u = Blog::User->retrieve(1);
    Blog::Bookmark->create(
        user_id => 1,
        entry_id => 10,
    );
    Blog::Bookmark->create(
        user_id => 1,
        entry_id => 11,
    );
    $u->flush('bookmarks');
    my %pre = %$cs;
    my $bs1 = $u->bookmarks(0,1);
    isa_ok $bs1, 'MoCo::List';
    is $bs1->size, 1;
    is $cs->{has_many_count}, $pre{has_many_count} + 1;
    is $cs->{has_many_cache_count}, $pre{has_many_cache_count};
    my $bs2 = $u->bookmarks(1,1);
    isa_ok $bs2, 'MoCo::List';
    is $bs2->size, 1;
    is $cs->{has_many_count}, $pre{has_many_count} + 2;
    is $cs->{has_many_cache_count}, $pre{has_many_cache_count};
    my $bs3 = $u->bookmarks(0,2);
    isa_ok $bs3, 'MoCo::List';
    is $bs3->size, 2;
    is $cs->{has_many_count}, $pre{has_many_count} + 3;
    is $cs->{has_many_cache_count}, $pre{has_many_cache_count} + 1;
    is $bs3->[0], $bs1->[0];
    is $bs3->[1], $bs2->[0];
    my $bs4 = $u->bookmarks(1,2);
    is $cs->{has_many_count}, $pre{has_many_count} + 4;
    is $cs->{has_many_cache_count}, $pre{has_many_cache_count} + 1;
    is $bs4->[0], $bs3->[1];
    my $bs5 = $u->bookmarks(0,3);
    is $cs->{has_many_count}, $pre{has_many_count} + 5;
    is $cs->{has_many_cache_count}, $pre{has_many_cache_count} + 2;
    is $bs5->[2], $bs4->[1];
}

sub delete_all : Tests {
    my $u = Blog::User->create(
        user_id => 20,
        name => '20 man',
    );
    Blog::Bookmark->create(
        user_id => 20,
        entry_id => 10,
    );
    Blog::Bookmark->create(
        user_id => 20,
        entry_id => 11,
    );
    ok $u->bookmarks;
    ok $u->bookmarks->size >= 2;
    Blog::Bookmark->delete_all(where => {user_id => 20});
    my $bs2 = $u->bookmarks;
    ok $bs2;
    ok $bs2->size == 0;
    my $bs = Blog::Bookmark->retrieve_all(where => {user_id => 20});
    ok $bs;
    ok $bs->size == 0;
}

sub param : Tests {
    my $u = Blog::User->create(
        user_id => 21,
        name => '21 man',
    );
    is $u->user_id, 21;
    is $u->name, '21 man';
    ok ($u->param(name => '21 girl'));
    is $u->name, '21 girl';
    ok ($u->name('21 lady'));
    is $u->name, '21 lady';
}

sub set : Tests {
    my $u = Blog::User->retrieve(1);
    ok !$u->param('hobby');
    $u->set(hobby => 'bike');
    is $u->hobby, 'bike';
}

sub retrieve_or_create : Tests {
    my $u = Blog::User->retrieve_or_create(
        user_id => 101,
        name => 'one-o-one',
    );
    ok $u;
    is $u->user_id, 101;
    is $u->name, 'one-o-one';
    my $u2 = Blog::User->retrieve_or_create(user_id => 101);
    ok $u2;
    is $u2, $u;
    is $u2->name, 'one-o-one';
}

sub object_ids : Tests {
    is_deeply (Blog::Entry->keys, ['uri']);
    my $e = Blog::Entry->retrieve(1);
    is_deeply ($e->object_ids, [
        'Blog::Entry-entry_id-1',
        'Blog::Entry-uri-http://test.com/entry-1'
    ]);
}

1;
