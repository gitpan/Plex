use 5.012000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Plex',
    VERSION_FROM      => 'lib/Plex.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Plex.pm', # retrieve abstract from module
       AUTHOR         => 'Daniel Zulla <scio@scix.de>') : ()),
    LIBS              => ['lib/Plex/Compiler.pm', 'lib/Plex/Lexer.pm', 'lib/Plex/Exception.pm', 'lib/Plex/String.pm', 'lib/Plex/Types.pm', 'lib/Plex/View.pm'], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => '-I.', # e.g., '-I. -I/usr/include/other'
	# Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too
);
