# ExtractSysbenchmutex.pm
package MMTests::ExtractSysbenchmutex;
use MMTests::SummariseMultiops;
use MMTests::Stat;
our @ISA = qw(MMTests::SummariseMultiops);
use strict;


sub initialise() {
	my ($self, $subHeading) = @_;
	$self->{_ModuleName} = "ExtractSysbenchmutex";
	$self->{_PlotYaxis}  = DataTypes::LABEL_TIME_USECONDS;
	$self->{_PlotType}   = "client-errorlines";
	$self->SUPER::initialise($subHeading);
}

sub extractReport() {
	my ($self, $reportDir) = @_;
	my @threads = $self->discover_scaling_parameters($reportDir, "sysbench-raw-", "-1");
	my $iteration;

	# Extract per-client timing information
	foreach my $thread (@threads) {
		my $iteration = 0;

		foreach my $file (<$reportDir/sysbench-raw-$thread-*>) {
			my $input = $self->SUPER::open_log($file);
			while (<$input>) {
				my $line = $_;

				if ($line =~ /avg:\s*(.*)/) {
					$self->addData($thread, ++$iteration, $1);
				}
			}
			close($input);
		}
	}
}

1;
