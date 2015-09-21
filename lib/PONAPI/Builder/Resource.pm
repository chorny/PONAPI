package PONAPI::Builder::Resource;
use Moose;

use PONAPI::Builder::Relationship;

with 'PONAPI::Builder',
     'PONAPI::Builder::Role::HasLinksBuilder',
     'PONAPI::Builder::Role::HasMeta';

has 'id'   => ( is => 'ro', isa => 'Str', required => 1 );
has 'type' => ( is => 'ro', isa => 'Str', required => 1 );

has '_attributes' => (
    traits  => [ 'Hash' ],
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { +{} },
    handles => {
        'has_attributes'    => 'count',
        'has_attribute_for' => 'exists',
        # private ...
        '_add_attribute' => 'set',
        '_get_attribute' => 'get',
    }
);

sub add_attribute {
    my $self  = $_[0];
    my $key   = $_[1];
    my $value = $_[2];

    $self->raise_error(
        title => 'Attribute key conflict, a relation already exists for key: ' . $key
    ) if $self->has_relationship_for( $key );

    $self->_add_attribute( $key, $value );

    return $self;
}

sub add_attributes {
    my ($self, %args) = @_;
    $self->add_attribute( $_, $args{ $_ } ) foreach keys %args;
    return $self;
}

has '_relationships' => (
    traits  => [ 'Hash' ],
    is      => 'ro',
    isa     => 'HashRef[ PONAPI::Builder::Relationship ]',
    lazy    => 1,
    default => sub { +{} },
    handles => {
        'has_relationships'    => 'count',
        'has_relationship_for' => 'exists',
        # private ...
        '_add_relationship' => 'set',
        '_get_relationship' => 'get',
    }
);

sub add_relationship {
    my ($self, $key, %args) = @_;

    $self->raise_error(
        title => 'Relationship key conflict, an attribute already exists for key: ' . $key
    ) if $self->has_attribute_for( $key );

    my $builder = PONAPI::Builder::Relationship->new( parent => $self, %args );
    $self->_add_relationship( $key => $builder );
    return $builder
}

sub build {
    my $self   = $_[0];
    my $result = {};

    $result->{id}            = $self->id;
    $result->{type}          = $self->type;
    $result->{attributes}    = $self->_attributes          if $self->has_attributes;
    $result->{links}         = $self->links_builder->build if $self->has_links_builder;
    $result->{meta}          = $self->_meta                if $self->has_meta;
    $result->{relationships} = {
        map {
            $_ => $self->_get_relationship( $_ )->build
        } keys %{ $self->_relationships }
    } if $self->has_relationships;

    return $result;
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;
