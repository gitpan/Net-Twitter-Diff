use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Net::Twitter::Diff',
    AUTHOR              => 'Tomohiro Teranishi <tomohiro.terranishi@gmail.com>',
    VERSION_FROM        => 'lib/Net/Twitter/Diff.pm',
    ABSTRACT_FROM       => 'lib/Net/Twitter/Diff.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'      => 0,
        'Net::Twitter'    => 0,
        'Array::Diff'     => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Net-Twitter-Diff-*' },
);
