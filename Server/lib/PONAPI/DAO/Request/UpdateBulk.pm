# ABSTRACT: DAO request - update bulk
package PONAPI::DAO::Request::UpdateBulk;

use Moose;

extends 'PONAPI::DAO::Request';

with 'PONAPI::DAO::Request::Role::UpdateLike',
     'PONAPI::DAO::Request::Role::HasDataBulk',
     'PONAPI::DAO::Request::Role::HasDataMethods';

has '+update_nothing_status' => (
    # http://jsonapi.org/format/#crud-updating-responses-404
    default => sub { 404 },
);

sub execute {
    my $self = shift;

    if ( $self->is_valid ) {
        my @ret = $self->repository->update( %{ $self } );

        # TODO: check for bulk
        # $self->_add_success_meta(@ret)
        #     if $self->_verify_update_response(@ret);
    }

    return $self->response();
}

__PACKAGE__->meta->make_immutable;
no Moose; 1;

__END__
