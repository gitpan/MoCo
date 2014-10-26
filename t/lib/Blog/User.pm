package Blog::User;
use strict;
use warnings;
use base qw 'Blog::Class';

__PACKAGE__->table('user');
__PACKAGE__->primary_keys(['user_id']);
__PACKAGE__->has_many(
    entries => 'Blog::Entry',
    { key => 'user_id' }
);
__PACKAGE__->has_many(
    bookmarks => 'Blog::Bookmark',
    { key => 'user_id' }
);

1;
