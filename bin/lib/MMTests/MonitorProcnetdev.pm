# MonitorProcnetdev.pm
package MMTests::MonitorProcnetdev;
use MMTests::SummariseMonitor;
our @ISA = qw(MMTests::SummariseMonitor);
use strict;

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName    => "MonitorProcnetdev",
	};
	bless $self, $class;
	return $self;
}

my %_colMap = (
	"interface"	=> 0,
	"rbytes"	=> 1,
	"rpackets"	=> 2,
	"rerrs"		=> 3,
	"rdrop"		=> 4,
	"rfifo"		=> 5,
	"rframe"	=> 6,
	"rcompressed"	=> 7,
	"rmulticast"	=> 8,
	"tbytes"	=> 9,
	"tpackets"	=> 10,
	"terrs"		=> 11,
	"tdrop"		=> 12,
	"tfifo"		=> 13,
	"tcolls"	=> 14,
	"tcarrier"	=> 15,
	"tcompressed"	=> 16,
);

use constant headings => {
	"rbytes"	=> "Received Bytes",
	"rpackets"	=> "Received Packets",
	"rerrs"		=> "Receive Errors",
	"rdrop"		=> "Receive Dropped Packets",
	"rfifo"		=> "Packets",
	"rframe"	=> "Packets",
	"rcompressed"	=> "Actions",
	"rmulticast"	=> "Packets",
	"tbytes"	=> "Transmitted Bytes",
	"tpackets"	=> "Transmitted Packets",
	"terrs"		=> "Transmit Errors",
	"tdrop"		=> "Transmit Dropped Packets",
	"tfifo"		=> "Packets",
	"tcolls"	=> "Transmit Collisions",
	"tcarrier"	=> "Actions",
	"tcompressed"	=> "Actions",
};

sub getPlotYaxis() {
	my ($self, $op) = @_;
	my ($interface, $field) = split(/-/, $op);

	return headings->{$field};
}

sub extractReport($$$$) {
	my ($self, $reportDir, $testBenchmark, $subHeading, $rowOrientated) = @_;
	my $timestamp;
	my $start_timestamp = 0;
	my $current_value = 0;

	if ($subHeading eq "") {
		die("Unrecognised heading");
	}

	my ($interface, $field) = split(/-/, $subHeading);

	if (!defined $_colMap{$field}) {
		die("Unrecognised heading");
	}

	my $input = $self->SUPER::open_log("$reportDir/proc-net-dev-$testBenchmark");
	while (<$input>) {
		if ($_ =~ /^time: ([0-9]+)/) {
			$timestamp = $1;
			if ($start_timestamp == 0) {
				$start_timestamp = $timestamp;
			}
		} else {
			$_ =~ s/^\s+//;
			my @fields = split(/\s+/, $_);

			if ($interface eq $fields[%_colMap{"interface"}]) {
				my $delta;

				if ($current_value == 0) {
					$current_value = $fields[%_colMap{$field}];
					$delta = 0;
				} else {
					$delta = $fields[%_colMap{$field}] - $current_value;
					$current_value = $fields[%_colMap{$field}];
				}

				$self->addData($subHeading,
					  $timestamp - $start_timestamp,
					  $delta);
			}
		}
	}
	close($input);
}

1;
