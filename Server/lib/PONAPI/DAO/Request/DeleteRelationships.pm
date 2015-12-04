package PONAPI::DAO::Request::DeleteRelationships;

use Moose;

use PONAPI::DAO::Constants;

extends 'PONAPI::DAO::Request';

with 'PONAPI::DAO::Request::Role::UpdateLike',
     'PONAPI::DAO::Request::Role::HasDataMethods',
     'PONAPI::DAO::Request::Role::HasID',
     'PONAPI::DAO::Request::Role::HasRelationshipType';

has data => (
    is        => 'ro',
    isa       => 'ArrayRef[HashRef]',
    predicate => 'has_data',
);

sub execute {
    my $self = shift;

    if ( $self->is_valid ) {
        local $@;
        eval {
            my @ret = $self->repository->delete_relationships( %{ $self } );

            $self->_add_success_meta(@ret)
                if $self->_verify_update_response(@ret);

            1;
        } or do {
            my $e = $@;
            $self->_handle_error($e);
        };
    }

    return $self->response();
}

sub _validate_rel_type {
    my $self = shift;

    return $self->_bad_request( "`relationship type` is missing" )
        unless $self->has_rel_type;

    my $type     = $self->type;
    my $rel_type = $self->rel_type;

    if ( !$self->repository->has_relationship( $type, $rel_type ) ) {
        $self->_bad_request( "Types `$type` and `$rel_type` are not related", 404 );
    }
    elsif ( !$self->repository->has_one_to_many_relationship( $type, $rel_type ) ) {
        $self->_bad_request( "Types `$type` and `$rel_type` are one-to-one" );
    }
}

sub _validate_data {
    my $self = shift;

    # these are chained to avoid multiple errors on the same issue
    $self->check_has_data
        and $self->check_data_has_type
        and $self->check_data_attributes()
        and $self->check_data_relationships();
}

__PACKAGE__->meta->make_immutable;
no Moose; 1;