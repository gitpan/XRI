# Copyright (C) 2004 Identity Commons.  All Rights Reserved.
# See LICENSE for licensing details

# Authors:
#       Fen Labalme <fen@idcommons.net>
#       Eugene Eric Kim <eekim@blueoxen.org>

package XRI::Descriptor;
use XRI::Descriptor::LocalAccess;
use XML::Smart;

sub new {
    my $self = shift;
    my $xml = shift;
    my $doc = XML::Smart->new( $xml );
    $doc = $doc->{XRIDescriptor};

    bless { doc=>$doc }, $self;
}

sub getResolved {
    my $self = shift;

    return $self->{doc}{Resolved};
}

# returns a reference to a list of URIs
#
sub getXRIAuthorityURIs {
    my $self = shift;

    return \@{$self->{doc}{XRIAuthority}{URI}};
}

sub getLocalAccess {
    my $self = shift;
    my ($service, $type) = @_;

    my @localAccessObjects;
    my @localAccessElements = @{$self->{doc}->{LocalAccess}};

    foreach my $element (@localAccessElements) {
        my $object = XRI::Descriptor::LocalAccess->new;
        $object->service($element->{Service}) if ($element->{Service});
        if (!$service || $object->service eq $service) {
            if ($element->{URI}) {
                # this conditional should be unnecessary if XML is valid.
                # according to the schema, there should always be at least
                # one URI per LocalAccess object.
                $object->uris($element->{URI});
            }
            $object->types($element->{Type}) if $element->{Type};
            if (!$type || grep(/^$type$/, $object->types)) {
                push @localAccessObjects, $object;
            }
        }
    }
    return @localAccessObjects;
}

sub getMappings {
    my $self = shift;

    return \@{$self->{doc}{Mapping}};
}

1;
