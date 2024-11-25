# ExtractEbizzyrange.pm
package MMTests::ExtractEbizzyrange;
use MMTests::SummariseMultiops;
use MMTests::Stat;
our @ISA = qw(MMTests::SummariseMultiops);
use strict;

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName  => "ExtractEbizzyrange",
		_PlotYaxis   => "Records/sec",
		_PreferredVal => "Higher",
	};
	bless $self, $class;
	return $self;
}

sub extractReport() {
	my ($self, $reportDir) = @_;

	foreach my $instance ($self->discover_scaling_parameters($reportDir, "ebizzy-", "-1.log")) {
		my $sample = 0;

		my @files = <$reportDir/ebizzy-$instance-*>;
		foreach my $file (@files) {
			my $input = $self->SUPER::open_log($file);
			while (<$input>) {
				my $line = $_;
				if ($line =~ /([0-9]*) records.*/) {
					my @elements = split(/\s+/, $line);
					shift @elements;
					shift @elements;
					$self->addData("spread-$instance", $sample, calc_range(\@elements));
					$sample++;
				}
			}
			close $input;
		}
	}
}

1;
