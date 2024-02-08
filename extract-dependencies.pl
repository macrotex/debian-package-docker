use strict ;
use warnings ;

my $dependencies = $ARGV[0] ;

# Step 1. Remove the initial "dpkg-checkbuilddeps: error: Unmet build dependencies:"
$dependencies =~ s{^dpkg-checkbuilddeps:.*Unmet[ ]build[ ]dependencies:}{}xsm;

# Step 2. Remove any version constraints (e.g., '(>= 13)')
$dependencies =~ s{(\([^\)]+\))}{}gxsm;

# Step 3. Remove any leading or trailing spaces.
$dependencies =~ s{^\s*}{}xsm;
$dependencies =~ s{\s*$}{}xsm;

# Now return the string of space-separated packages.
print $dependencies;

