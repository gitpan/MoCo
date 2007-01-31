use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'MoCo',
    VERSION_FROM      => 'lib/MoCo.pm',
    PREREQ_PM         => {
        Class::Trigger => '',
        SQL::Abstract => '',
        DBI => '',
        DBD::SQLite => '',
        List::Util => '',
        List::MoreUtils => '',
        Exporter => '',
        Cache::Memory => '',
    },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/MoCo.pm',
       AUTHOR         => 'Junya Kondo <jkondo@hatena.com>') : ()),
);
