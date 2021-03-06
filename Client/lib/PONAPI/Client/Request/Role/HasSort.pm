# ABSTRACT: PONAPI - Perl implementation of {JSON:API} (http://jsonapi.org/) v1.0
package PONAPI::Client::Request::Role::HasSort;

use Moose::Role;

has sort => (
    is        => 'ro',
    isa       => 'ArrayRef',
    predicate => 'has_sort',
);

no Moose::Role; 1;

__END__
