#!/bin/bash

pcreDownloadURL='ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.35.tar.gz'

pcreInstallFolder='/opt/pcre'

pcreConfig=(
    '--enable-ebcdic'
    '--enable-jit'
    '--enable-pcre16'
    '--enable-pcre32'
    '--enable-pcregrep-libbz2'
    '--enable-pcregrep-libz'
    '--enable-unicode-properties'
    '--enable-utf8'
    '--enable-utf'
)