# ExtractLkpthroughput.pm
package MMTests::ExtractLkpthroughput;
use MMTests::SummariseMultiops;
use MMTests::Stat;
our @ISA = qw(MMTests::SummariseMultiops);
use strict;
use Data::Dumper qw(Dumper);

sub initialise() {
	my ($self, $subHeading) = @_;

	$self->{_ModuleName} = "ExtractLkpthroughput";
	$self->{_PlotYaxis}  = DataTypes::LABEL_MBYTES_PER_SECOND;
	$self->{_PreferredVal} = "Higher";
	$self->{_PlotType}   = "thread-errorlines";
	$self->SUPER::initialise($subHeading);
}

sub uniq {
	my %seen;
	grep !$seen{$_}++, @_;
}

sub extractReport() {
	my ($self, $reportDir) = @_;
	my ($tp, $name);
	my @workloads = split(/,/, <INPUT>);
	$self->{_Workloads} = \@workloads;
	close(INPUT);

	my @threads = $self->discover_scaling_parameters($reportDir, "lkp-", "-1.log");
	@threads = uniq(@threads);

	foreach my $nthr (@threads) {
		foreach my $file (<$reportDir/lkp-$nthr-*.log>) {
			my $nr_samples = 0;

			my $input = $self->SUPER::open_log($file);
			while (<$input>) {
				my $line = $_;
				my @tmp = split(/\s+/, $line);

				if ($line =~ /^throughput: ([0-9.]*)/) {
					$self->addData("tput-$nthr", ++$nr_samples, $1);
				}
			}
			close $input;
		}
	}
}
