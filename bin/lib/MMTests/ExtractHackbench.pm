# ExtractHackbench.pm
package MMTests::ExtractHackbench;
use MMTests::SummariseMultiops;
our @ISA = qw(MMTests::SummariseMultiops);

sub initialise() {
	my ($self, $subHeading) = @_;
	$self->{_ModuleName} = "ExtractHackbench";
	$self->{_PlotYaxis}  = DataTypes::LABEL_TIME_SECONDS;
	$self->{_PlotType}   = "group-errorlines";
	$self->{_Precision} = 4;

	$self->SUPER::initialise($subHeading);
}

sub extractReport() {
	my ($self, $reportDir) = @_;

	my @groups = $self->discover_scaling_parameters($reportDir, "hackbench-", "-1");
	foreach my $group (@groups) {
		my $nr_samples = 0;
		foreach my $file (<$reportDir/hackbench-$group-*>) {
			my $input = $self->SUPER::open_log($file);
			while (<$input>) {
				if ($_ !~ /Total time: ([0-9.]*)/) {
					next;
				}
				my $walltime = $1;
				$self->addData($group, ++$nr_samples, $walltime);
			}
			close $input;
		}
	}
}
1;
