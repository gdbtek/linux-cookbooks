#!/bin/bash -e

export pcreDownloadURL='ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.36.tar.gz'

export pcreInstallFolder='/opt/pcre'

export pcreConfig=(
    "--prefix=${pcreInstallFolder}"
    '--disable-bsr-anycrlf'
    '--enable-jit'
    '--enable-newline-is-lf'
    '--enable-pcre16'
    '--enable-pcre32'
    '--enable-pcre8'
    '--enable-pcregrep-libbz2'
    '--enable-pcregrep-libz'
    '--enable-rebuild-chartables'
    '--enable-shared'
    '--enable-static'
    '--enable-unicode-properties'
    '--enable-utf'
    '--enable-valgrind'
    '--with-link-size=2'
    '--with-match-limit=10000000'
    '--with-parens-nest-limit=250'
    '--with-pcregrep-bufsize=20480'
    '--with-posix-malloc-threshold=10'
)

# '--enable-coverage'