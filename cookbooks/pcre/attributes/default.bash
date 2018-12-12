#!/bin/bash -e

export PCRE_DOWNLOAD_URL='https://ftp.pcre.org/pub/pcre/pcre-8.42.tar.gz'

export PCRE_INSTALL_FOLDER_PATH='/opt/pcre'

export PCRE_CONFIG=(
    '--enable-bsr-anycrlf'
    '--enable-dependency-tracking'
    '--enable-fast-install'
    '--enable-jit'
    '--enable-newline-is-any'
    '--enable-newline-is-anycrlf'
    '--enable-newline-is-cr'
    '--enable-newline-is-crlf'
    '--enable-newline-is-lf'
    '--enable-pcre-16'
    '--enable-pcre-32'
    '--enable-pcre-8'
    '--enable-pcregrep-libbz2'
    '--enable-pcregrep-libz'
    '--enable-rebuild-chartables'
    '--enable-shared'
    '--enable-static'
    '--enable-utf'
    '--enable-valgrind'
    "--prefix=${PCRE_INSTALL_FOLDER_PATH}"
    '--with-aix-soname=both'
    '--with-gnu-ld=no'
    '--with-link-size=2'
    '--with-match-limit=10000000'
    '--with-match-limit-recursion=MATCH_LIMIT'
    '--with-parens-nest-limit=250'
    '--with-pcregrep-bufsize=20480'
)