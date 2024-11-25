# ExtractReaim.pm
package MMTests::ExtractReaim;
use MMTests::SummariseMultiops;
use MMTests::Stat;
our @ISA = qw(MMTests::SummariseMultiops);
use strict;

sub initialise() {
	my ($self, $subHeading) = @_;
	$self->{_ModuleName} = "ExtractReaim";
	$self->{_PlotYaxis}  = DataTypes::LABEL_OPS_PER_MINUTE,
	$self->{_PlotType}   = "process-errorlines";
	$self->{_PreferredVal} = "Higher";
	$self->SUPER::initialise($subHeading);
}

sub extractReport() {
	my ($self, $reportDir) = @_;
	my $required_heading = "JPM";

	my @workfiles = <$reportDir/workfile.*>;
	foreach my $workfile (@workfiles) {
		my $worktitle = $workfile;
		$worktitle =~ s/.*\.//;

		my $file = "$workfile/reaim.csv";
		open(INPUT, $file) || die("Failed to open $file\n");

		# Read the header and find the appropriate field
		my @elements = split(/,/, <INPUT>);
		my $index = -1;
		foreach my $element (@elements) {
			$index++;
			if ($element eq $required_heading) {
				last;
			}
		}

		while (<INPUT>) {
			my $line = $_;
			@elements = split(/,/, $line);
			$self->addData("$worktitle-$elements[0]", 1, $elements[$index]);
		}
		close INPUT;
	}
}

1;
