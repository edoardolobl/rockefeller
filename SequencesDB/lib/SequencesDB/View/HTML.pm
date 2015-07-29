package SequencesDB::View::HTML;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    INCLUDE_PATH => [
        SequencesDB->path_to( 'root', 'src' ),
        SequencesDB->path_to( 'root', 'lib' )
    ],
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'error.tt2',
    TIMER        => 0,
    render_die   => 1,
    CACHE_SIZE	 => 0,
    STAT_TTL	 => 0,
});

=head1 NAME

SequencesDB::View::HTML - Catalyst TT Twitter Bootstrap View

=head1 SYNOPSIS

See L<SequencesDB>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

Edoardo,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

