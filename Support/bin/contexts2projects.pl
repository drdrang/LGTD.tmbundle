#!/usr/bin/env perl

# Project and context files.
$context_file = "$ENV{'TM_LGTD_DIRECTORY'}/contexts.gtd";
$project_file = ">$ENV{'TM_LGTD_DIRECTORY'}/projects.gtd";

# Initialize the actions and waiting hashes.
%actions = ();
%waiting = ();

# Read in one context at a time.
$/ = "\n# ";

# Open the contexts file for reading.
open CONTEXTS, $context_file or die "Can't open contexts file: $!";

# Loop through the contexts, gathering all the next action lines
# and adding them to the actions hash and all the hold lines and
# adding them to the waiting hash.
while ($stanza = <CONTEXTS>) {
  @lines = split("\n", $stanza);
  ($context) = shift(@lines) =~ /^#? ?([^]]+) #$/m;
  $context = lc($context);
  if ($context eq 'waiting for') {
    $context =~ s/ for$//;
    for (@lines) {
      if (/^-/) {
        ($hold, $project) = /^(-[^[]+) +\[([^]]+)]/;
        $waiting{$project} .= "$hold\n";
      }
    }
  }
  else {
    for (@lines) {
      if (/^\*/) {
        ($act, $project) = /^(\*[^[]+) +\[([^]]+)]/;
        $actions{$project} .= "$act [$context]\n";
      }
    }
  }
}
close CONTEXTS;

# Create a list of all the projects.
@projects = keys %actions;
push @projects, keys %waiting;
%unique = map { $_ => 1 } @projects;  # this eliminates duplicates
@projects = sort keys %unique;

# Open the projects file for printing.
open PROJECTS, $project_file or die "Can't open projects file: $!";
select PROJECTS;

# Print the next actions and waitings according to project.
for $project (@projects) {
  print "# $project #\n\n";
  print "Next actions:\n\n";
  print "$actions{$project}\n";
  print "Waiting for:\n\n";
  print "$waiting{$project}\n";
}
close PROJECTS;
