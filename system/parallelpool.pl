#!/usr/bin/perl -w

# Parallelpool - Run a bunch of proccesses in parallel, similar to
# make's -j option.

# Erasmus Darwin, 2008.  No rights reserved.  This is just a quick
# hack and doesn't conform to proper coding conventions.  It also does
# some inefficient stuff like creating an array of all arguments.  Do
# with this what you want.  You can even remove my name and claim you
# wrote it.

# Based on an idea by SA's willcodeforfoo.

use Getopt::Std;

sub usage() {
    print STDERR "parallelpool [-s (pool size)] -c (command) (-i (input-file) [-a (args)] | -l (loop-range))\n\n";
    print STDERR " -s - Number of processes to run simultaneously (default 2)\n";
    print STDERR " -c - Command to run\n";
    print STDERR " -i - File containing command arguments, 1 per line\n";
    print STDERR " -a - Number of arguments per command invocation (default 1)\n";
    print STDERR " -l - Loop range for command arguments (ex: 1-100)\n";
    print STDERR " -? - This help\n";
}

getopts('s:c:i:a:l:?', \%opt);

if (! defined($opt{s})) {
    $opt{s} = 2;
}

if (! defined($opt{a})) {
    $opt{a} = 1;
}

if ($opt{'?'} || ! $opt{c} || $opt{s} < 1 || $opt{a} < 1 ||
    (! defined($opt{i}) && ! defined($opt{l}))) {
    usage();
    exit(-1);
}

if (defined($opt{l})) {
    if ($opt{l} =~ /^(-?\d+)(?:-|\.\.)(-?\d+)$/) {
	if ($1 <= $2) {
	    $start = $1;
	    $end = $2;
	} else {
	    $start = $2;
	    $end = $1;
	}
	push @args, ($start .. $end);
    } else {
	print STDERR "Invalid range: $opt{l}\n";
	exit(-1);
    }
}

if (defined($opt{i})) {
    open(F, '<', $opt{i}) or die "Can't open $opt{i}: $!";
    @tmp = map { chomp; $_; } <F>;
    close(F);

    if ($opt{a} == 1) {
	# Optimization for the trivial case.
	push @args, @tmp;
	undef @tmp;
    } else {
	if (@tmp % $opt{a} != 0) {
	    print STDERR "Number of arguments in $opt{i} isn't a multiple of $opt{a} (-a setting)\n";
	    exit(-1);
	}
	while (@tmp) {
	    push @args, [ ];
	    for ($i=0; $i<$opt{a}; ++$i) {
		push @{$args[-1]}, shift(@tmp);
	    }
	}
    }
}

$proc_cnt = 0;
while (@args || $proc_cnt) {
    while ($proc_cnt < $opt{s} && @args) {
	$arg = shift(@args);
	$pid = fork();
	if (! defined($pid)) {
	    die "Fork failure: $!";
	}
	if ($pid == 0) {
	    if (ref($arg) eq 'ARRAY') {
		exec($opt{c}, @{$arg});
	    } else {
		exec("$opt{c} $arg");
	    }
	    die "Exec failed: $!";
	}
	print "Child $pid spawned: $opt{c} ",
	      (ref($arg) eq 'ARRAY' ? join(' ', @{$arg}) : $arg), "\n";
	$proc_cnt++;
    }
    $dead_pid = wait();
    if ($dead_pid == -1) {
	die "wait() returned -1";
    }
    print "Child $dead_pid exited with status $?\n";
    $proc_cnt--;
}
