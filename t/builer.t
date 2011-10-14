#!perl

BEGIN {
    use Test::MockTime qw(set_fixed_time restore_time );
}

use Test::MockObject::Extends;
use Test::More;
use Devel::Cover::Report::Clover::Builder;

use FindBin;
use lib ($FindBin::Bin);
use testcover;

my $EMPTY_DB = testcover::run('Empty');

my @test = (
    sub {
        my $t = "template_dir - returns valid folder";

        my $ret = Devel::Cover::Report::Clover::Builder::template_dir();

        ok( -d $ret, $t );
    },
    sub {
        my $t = "template_file - which template file to use";

        my $ret    = Devel::Cover::Report::Clover::Builder::template_file();
        my $expect = 'clover.tt';

        is( $ret, $expect, $t );
    },
    sub {
        my $t = "new - file registry object created";

        my $b = BUILDER( { name => 'test', db => $EMPTY_DB } );
        ok( $b->file_registry, $t );
    },
    sub {
        my $t = "new - project created";

        my $b = BUILDER( { name => 'test', db => $EMPTY_DB } );
        ok( $b->project, $t );
    },
    sub {
        my $expect = 'test';
        my $t      = "new - project created - name is $expect";

        my $b = BUILDER( { name => $expect, db => $EMPTY_DB } );
        is( $b->project->name, $expect, $t );
    },
    sub {
        my $t = "report - top level structure looks good";

        my $b = BUILDER( { name => 'Project Name', db => $EMPTY_DB } );

        my $project = $b->project;
        $project = Test::MockObject::Extends->new($project);
        $project->mock( 'report', sub { return {} } );
        $b->project($project);

        set_fixed_time(123456789);
        my $report = $b->report();
        my $expect = {
            generated_by => 'Devel::Cover::Report::Clover',
            version      => $Devel::Cover::Report::Clover::VERSION,
            generated    => time(),
            project      => $project->report(),

        };
        restore_time();

        is_deeply( $report, $expect, $t );

    },

);

plan tests => scalar @test;

$_->() foreach @test;

sub BUILDER {
    return Devel::Cover::Report::Clover::Builder->new(shift);
}
