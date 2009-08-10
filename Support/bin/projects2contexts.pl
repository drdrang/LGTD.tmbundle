#!/usr/bin/env perl

# Project and context files.
$project_file = "$ENV{'TM_LGTD_DIRECTORY'}/projects.gtd";
$context_file = ">$ENV{'TM_LGTD_DIRECTORY'}/contexts.gtd";

# Initialize the actions hash and the waiting string.
%actions = ();
$waiting = '';

# Read in one project at a time.
$/ = "\n# ";

# Open the project file for reading.
open PROJECTS, $project_file or die "Can't open projects file: $!";

# Loop through the projects, gathering all the next action lines
# and adding them to the contexts hash.
while ($stanza = <PROJECTS>) {
  @lines = split("\n", $stanza);
  ($project) = shift(@lines) =~ /^#? ?([^]]+) #$/m;
  for (@lines) {
    if (/^\*/) {
      ($act, $context) = /^(\*[^[]+) +\[([^]]+)]/;
      $actions{$context} .= "$act [$project]\n";
    }
    elsif (/^-/) {
      chomp;
      $waiting .= "$_ [$project]\n";
    }
    else {
      next;
    }
  }
}
close PROJECTS;

# Open the contexts file for printing.
open CONTEXTS, $context_file or die "Can't open context file: $!";
select CONTEXTS;

# Print the next actions according to context.
for (sort keys %actions) {
  $title = $_;
  substr($title, 0, 1) =~ tr/a-z/A-Z/;
  print "# $title #\n\n";
  print $actions{$_};
  print "\n";
}

# Print the things we're waiting for.
print "# Waiting for #\n\n";
print $waiting;

close CONTEXTS;
