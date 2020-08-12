#!/usr/bin/perl

use strict ;
use warnings ;
use autodie ;

my @debian_distributions = qw (
    unstable
    buster
) ;

# 1. Make the Dockerfiles
foreach my $distribution (@debian_distributions) {
    my $outfile = "Dockerfile-$distribution";
    open(my $OUT, '>', $outfile) ;
    open(my $IN,  '<', 'Dockerfile.template') ;

    while (my $line = <$IN>) {
        $line =~ s{%%DEBIAN_DISTRIBUTION%%}{$distribution}gxsm ;
        print $OUT $line ;
    }

    close($OUT) ;
    close($IN) ;
}

# 2. Make action YAML file.
my $action_header = <<'EOH';
name: Build Docker images

# This workflow is triggered on pushes to the repository:
on: [push]

jobs:
  build_docker_images:
    name: Build Docker Images
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
EOH


my $outfile = '.github/workflows/docker.yml';
open(my $OUT, '>', $outfile);

print $OUT $action_header ;

foreach my $distribution (@debian_distributions) {
    my $docker_clause = <<"EOC";

      - name: Build and push Docker image $distribution
        uses: docker/build-push-action\@v1
        with:
          # We omit the "registry" parameter so it defaults to
          # DockerHub
          dockerfile: Dockerfile-$distribution
          username: \${{ secrets.DOCKERHUB_USERNAME }}
          password: \${{ secrets.DOCKERHUB_PASSWORD }}
          repository: macrotex/debian-package-docker
          tag_with_ref: false
          tag_with_sha: false
          tags: $distribution
EOC

    print $OUT $docker_clause ;
}

close($OUT) ;


