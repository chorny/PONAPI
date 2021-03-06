# ABSTRACT: PONAPI - Perl implementation of {JSON:API} (http://jsonapi.org/) v1.0
package PONAPI::Client::Request;

use Moose::Role;

use JSON::XS qw< encode_json >;

use PONAPI::Utils::URI qw< to_uri >;

requires 'method';
requires 'path';

sub request_params {
    my $self = shift;

    my $method = $self->method;

    return (
        method => $method,
        path   => $self->path,
        ( $method eq 'GET'
            ? ( query_string => $self->_build_query_string )
            : ( $self->can('data')
                  ? ( body => encode_json( { data => $self->data } ) )
                  : ()
              )
        )
    );
}

sub _build_query_string {
    my $self = shift;

    my %u;

    $u{filter} = $self->filter
        if $self->does('PONAPI::Client::Request::Role::HasFilter') and $self->has_filter;

    $u{fields} = $self->fields
        if $self->does('PONAPI::Client::Request::Role::HasFields') and $self->has_fields;

    $u{page} = $self->page
        if $self->does('PONAPI::Client::Request::Role::HasPage') and $self->has_page;

    $u{include} = $self->include
        if $self->does('PONAPI::Client::Request::Role::HasInclude') and $self->has_include;

    $u{sort} = $self->sort
        if $self->does('PONAPI::Client::Request::Role::HasSort') and $self->has_sort;

    return to_uri( \%u );
}

no Moose::Role; 1;

__END__
