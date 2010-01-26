#!/usr/bin/env perl

# Include the directory where Markdown.pm is kept.
use lib "$ENV{'TM_BUNDLE_SUPPORT'}/lib";

# The full path to the html2ps rc file for printing to index cards.
$html2psrc = "$ENV{'TM_BUNDLE_SUPPORT'}/html2psrc-hpda";

# The print command to which the PDF output is piped.
my $lpr = "lpr -o ManualFeed=True";

# The top of the HTML document.
my $top = <<"TOP";
<html>
<head>
</head>
<body>
TOP

# The bottom of the HTML document.
my $bottom = <<BOTTOM;

</body>
</html>
BOTTOM

# Slurp in the text.
my $original;
{
  local $/;
  $original = <>;
}

# Get rid of the title line.
$original =~ s/^Contexts$|^Projects$//m;

# Filter the rest through Markdown.
use Markdown;
my $middle = Markdown::Markdown($original);

# Put page break comments before each <h1> except the first. Have to
# insert the comments from back to front to keep the offsets correct.
my @offsets = ();
my $position;
while ($middle =~ m/<h1>/g) {
  unshift @offsets, pos($middle) - 4;   # collect positions in reverse order
}
pop @offsets;                           # get rid of the last (first) one
for $position (@offsets) {
  substr($middle, $position, 0, "<!--NewPage-->\n");
}

# Tell me to go to the printer.
print "Waiting for manual feed of 3x5 index card(s)";

# Form the HTML and send it through the pipeline.
my $html = $top . $middle . $bottom;
open OUT, "| html2ps -f '$html2psrc' | $ENV{'TM_LGTD_PS2PDF'} - | $lpr";
# open OUT, "| html2ps -f '$html2psrc' | $ENV{'TM_LGTD_PS2PDF'} - ~/Desktop/out.pdf";
print OUT $html;
close OUT;
