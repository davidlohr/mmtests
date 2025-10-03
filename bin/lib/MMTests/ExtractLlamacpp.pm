# ExtractLlamacpp.pm
package MMTests::ExtractLlamacpp;
use MMTests::SummariseMultiops;
use MMTests::Stat;
our @ISA = qw(MMTests::SummariseMultiops);
use strict;

sub initialise() {
	my ($self, $subHeading) = @_;
	$self->{_ModuleName} = "ExtractLlamacpp";
	$self->{_PlotYaxis}  = "Tokens/sec";
	$self->{_PreferredVal} = "Higher";
	$self->{_PlotType}   = "thread-errorlines";
	$self->SUPER::initialise($subHeading);
}

sub extractReport() {
	my ($self, $reportDir) = @_;
	
	# First check for thread-scaled logs (new format)
	my @threads = $self->discover_scaling_parameters($reportDir, "llamacpp-", "-1.log");
	
	if (@threads) {
		# Extract performance information from thread-scaled logs
		my %test_types_seen;
		my %samples;
		
		foreach my $thread (@threads) {
			foreach my $file (<$reportDir/llamacpp-$thread-*.log>) {
				my $input = $self->SUPER::open_log($file);
				while (<$input>) {
					my $line = $_;
					# Parse llama-bench output format:
					# | llama 7B Q4_K - Medium         |   3.80 GiB |     6.74 B | CPU        |      12 |     512 |           pp512 |         11.67 ± 0.97 |
					# | llama 7B Q4_K - Medium         |   3.80 GiB |     6.74 B | CPU        |      12 |     512 |           tg128 |          5.97 ± 1.15 |
					# | llama 7B Q4_K - Medium         |   3.80 GiB |     6.74 B | CPU        |      12 |     512 |      pp1024+tg256 |         11.67 ± 0.97 |
					if ($line =~ /\|\s+.*\|\s+.*\|\s+.*\|\s+.*\|\s+(\d+)\s+\|\s+(\d+)\s+\|\s+(\d+)\s+\|\s+(pp\d+\+tg\d+|pp\d+|tg\d+)\s+\|\s+([0-9.]+)\s+±/) {
						my $threads_used = $1;
						my $batch_size = $2;
						my $fa = $3;
						my $test_type = $4;
						my $performance = $5;
						
						# Remove + character from test_type to avoid shell/filename issues
						my $clean_test_type = $test_type;
						$clean_test_type =~ s/\+//g;
						my $key = "$clean_test_type-$threads_used";
						$test_types_seen{$key} = 1;
						$samples{$key}++;
						$self->addData($key, $samples{$key}, $performance);
					}
				}
				close($input);
			}
		}
		
		# Build operations list: test_type-threads for each combination
		my @ops;
		foreach my $key (sort keys %test_types_seen) {
			push @ops, $key;
		}
		$self->{_Operations} = \@ops;
	} else {
		# Fallback to old format (llamacpp-N.log)
		my $iteration = 0;
		foreach my $file (<$reportDir/llamacpp-*.log>) {
			my $input = $self->SUPER::open_log($file);
			while (<$input>) {
				my $line = $_;
				if ($line =~ /\|\s+.*\|\s+.*\|\s+.*\|\s+.*\|\s+(\d+)\s+\|\s+\d+\s+\|\s+\d+\s+\|\s+(pp\d+\+tg\d+|pp\d+|tg\d+)\s+\|\s+([0-9.]+)\s+±/) {
					my $threads_used = $1;
					my $test_type = $2;
					my $performance = $3;
					# Remove + character from test_type to avoid shell/filename issues
					my $clean_test_type = $test_type;
					$clean_test_type =~ s/\+//g;
					$self->addData("$clean_test_type-$threads_used", ++$iteration, $performance);
				}
			}
			close($input);
		}
	}
}

1;