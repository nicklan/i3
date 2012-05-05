#!perl
# vim:ts=4:sw=4:expandtab
# Tests resizing tiling containers
use i3test;

my $tmp = fresh_workspace;

cmd 'split v';

my $top = open_window;
my $bottom = open_window;

diag("top = " . $top->id . ", bottom = " . $bottom->id);

is($x->input_focus, $bottom->id, 'Bottom window focused');

############################################################
# resize
############################################################

cmd 'resize grow up 10 px or 25 ppt';

my ($nodes, $focus) = get_ws_content($tmp);

ok(cmp_float($nodes->[0]->{percent}, 0.25), 'top window got only 25%');
ok(cmp_float($nodes->[1]->{percent}, 0.75), 'bottom window got 75%');


############################################################
# split and check if the 'percent' factor is still correct
############################################################

cmd 'split h';

($nodes, $focus) = get_ws_content($tmp);

ok(cmp_float($nodes->[0]->{percent}, 0.25), 'top window got only 25%');
ok(cmp_float($nodes->[1]->{percent}, 0.75), 'bottom window got 75%');

############################################################
# checks that resizing within stacked/tabbed cons works
############################################################

$tmp = fresh_workspace;

cmd 'split v';

$top = open_window;
$bottom = open_window;

cmd 'split h';
cmd 'layout stacked';

($nodes, $focus) = get_ws_content($tmp);
ok(cmp_float($nodes->[0]->{percent}, 0.5), 'top window got 50%');
ok(cmp_float($nodes->[1]->{percent}, 0.5), 'bottom window got 50%');

cmd 'resize grow up 10 px or 25 ppt';

($nodes, $focus) = get_ws_content($tmp);
ok(cmp_float($nodes->[0]->{percent}, 0.25), 'top window got 25%');
ok(cmp_float($nodes->[1]->{percent}, 0.75), 'bottom window got 75%');

############################################################
# Checks that resizing in the parent's parent's orientation works.
# Take for example a horizontal workspace with one window on the left side and
# a v-split container with two windows on the right side. Focus is on the
# bottom right window, use 'resize left'.
############################################################

$tmp = fresh_workspace;

my $left = open_window;
my $right = open_window;

cmd 'split v';

$top = open_window;
$bottom = open_window;

($nodes, $focus) = get_ws_content($tmp);
ok(cmp_float($nodes->[0]->{percent}, 0.5), 'left window got 50%');
ok(cmp_float($nodes->[1]->{percent}, 0.5), 'right window got 50%');

cmd 'resize grow left 10 px or 25 ppt';

($nodes, $focus) = get_ws_content($tmp);
ok(cmp_float($nodes->[0]->{percent}, 0.25), 'left window got 25%');
ok(cmp_float($nodes->[1]->{percent}, 0.75), 'right window got 75%');

################################################################################
# Check that the resize grow/shrink width/height syntax works.
################################################################################

# Use two windows
$tmp = fresh_workspace;

$left = open_window;
$right = open_window;

cmd 'resize grow width 10 px or 25 ppt';

($nodes, $focus) = get_ws_content($tmp);
ok(cmp_float($nodes->[0]->{percent}, 0.25), 'left window got 25%');
ok(cmp_float($nodes->[1]->{percent}, 0.75), 'right window got 75%');

# Now test it with four windows
$tmp = fresh_workspace;

open_window for (1..4);

cmd 'resize grow width 10 px or 25 ppt';

($nodes, $focus) = get_ws_content($tmp);
ok(cmp_float($nodes->[0]->{percent}, 0.166666666666667), 'first window got 16%');
ok(cmp_float($nodes->[1]->{percent}, 0.166666666666667), 'second window got 16%');
ok(cmp_float($nodes->[2]->{percent}, 0.166666666666667), 'third window got 16%');
ok(cmp_float($nodes->[3]->{percent}, 0.50), 'fourth window got 50%');

# height should be a no-op in this situation
cmd 'resize grow height 10 px or 25 ppt';

($nodes, $focus) = get_ws_content($tmp);
ok(cmp_float($nodes->[0]->{percent}, 0.166666666666667), 'first window got 16%');
ok(cmp_float($nodes->[1]->{percent}, 0.166666666666667), 'second window got 16%');
ok(cmp_float($nodes->[2]->{percent}, 0.166666666666667), 'third window got 16%');
ok(cmp_float($nodes->[3]->{percent}, 0.50), 'fourth window got 50%');


############################################################
# checks that resizing floating windows works
############################################################

$tmp = fresh_workspace;

$top = open_window;

cmd 'floating enable';

my @content = @{get_ws($tmp)->{floating_nodes}};
cmp_ok(@content, '==', 1, 'one floating node on this ws');

# up
my $oldrect = $content[0]->{rect};

cmd 'resize grow up 10 px or 25 ppt';

@content = @{get_ws($tmp)->{floating_nodes}};
cmp_ok($content[0]->{rect}->{y}, '<', $oldrect->{y}, 'y smaller than before');
cmp_ok($content[0]->{rect}->{y}, '==', $oldrect->{y} - 10, 'y exactly 10 px smaller');
cmp_ok($content[0]->{rect}->{x}, '==', $oldrect->{x}, 'x untouched');
cmp_ok($content[0]->{rect}->{height}, '>', $oldrect->{height}, 'height bigger than before');
cmp_ok($content[0]->{rect}->{height}, '==', $oldrect->{height} + 10, 'height exactly 10 px higher');
cmp_ok($content[0]->{rect}->{width}, '==', $oldrect->{width}, 'x untouched');

# up, but with a different amount of px
$oldrect = $content[0]->{rect};

cmd 'resize grow up 12 px or 25 ppt';

@content = @{get_ws($tmp)->{floating_nodes}};
cmp_ok($content[0]->{rect}->{y}, '<', $oldrect->{y}, 'y smaller than before');
cmp_ok($content[0]->{rect}->{y}, '==', $oldrect->{y} - 12, 'y exactly 10 px smaller');
cmp_ok($content[0]->{rect}->{x}, '==', $oldrect->{x}, 'x untouched');
cmp_ok($content[0]->{rect}->{height}, '>', $oldrect->{height}, 'height bigger than before');
cmp_ok($content[0]->{rect}->{height}, '==', $oldrect->{height} + 12, 'height exactly 10 px higher');
cmp_ok($content[0]->{rect}->{width}, '==', $oldrect->{width}, 'x untouched');

# left
$oldrect = $content[0]->{rect};

cmd 'resize grow left 10 px or 25 ppt';

@content = @{get_ws($tmp)->{floating_nodes}};
cmp_ok($content[0]->{rect}->{x}, '<', $oldrect->{x}, 'x smaller than before');
cmp_ok($content[0]->{rect}->{width}, '>', $oldrect->{width}, 'width bigger than before');

# right
$oldrect = $content[0]->{rect};

cmd 'resize grow right 10 px or 25 ppt';

@content = @{get_ws($tmp)->{floating_nodes}};
cmp_ok($content[0]->{rect}->{x}, '==', $oldrect->{x}, 'x the same as before');
cmp_ok($content[0]->{rect}->{y}, '==', $oldrect->{y}, 'y the same as before');
cmp_ok($content[0]->{rect}->{width}, '>', $oldrect->{width}, 'width bigger than before');
cmp_ok($content[0]->{rect}->{height}, '==', $oldrect->{height}, 'height the same as before');

# down
$oldrect = $content[0]->{rect};

cmd 'resize grow down 10 px or 25 ppt';

@content = @{get_ws($tmp)->{floating_nodes}};
cmp_ok($content[0]->{rect}->{x}, '==', $oldrect->{x}, 'x the same as before');
cmp_ok($content[0]->{rect}->{y}, '==', $oldrect->{y}, 'y the same as before');
cmp_ok($content[0]->{rect}->{height}, '>', $oldrect->{height}, 'height bigger than before');
cmp_ok($content[0]->{rect}->{width}, '==', $oldrect->{width}, 'width the same as before');

done_testing;
