# First let's remove from heacore everything except ape, so
# we won't be building things we do not need
mkdir backup
mv heacore/ape heacore/BUILD_DIR backup
rm -rf heacore/*
mv backup/* heacore/

export CFLAGS="-I${PREFIX}/include ${CFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"

# Make configure believe we have a Fortran compiler even though
# we don't. Ape does not need Fortran, and we want to avoid
# having to install a fortran compiler just to make "configure"
# happy
export F77=":"

# For the same reason, let's make a fake readline/configure for readline
# (which we do not actually need to build) otherwise the main "configure"
# will go into an endless loop

mkdir -p heacore/readline
echo '#!/bin/bash' > heacore/readline/configure
chmod u+x heacore/readline/configure

# We can now configure and build
cd heacore/BUILD_DIR

./configure --with-components="ape" LDFLAGS="${LDFLAGS}"

./hmake

# Now copy the products. We do not use ./hmake install because
# it copies things in the wrong place for this partial build
cd ..
mkdir -p  ${PREFIX}/bin && cp -rf --dereference BLD/*/bin/* ${PREFIX}/bin
mkdir -p  ${PREFIX}/lib && cp -rf --dereference BLD/*/lib/libape* ${PREFIX}/lib
mkdir -p  ${PREFIX}/include && cp -rf --dereference BLD/*/include/* ${PREFIX}/include
mkdir -p  ${PREFIX}/share/doc/ape && cp -rf --dereference BLD/*/help/* ${PREFIX}/share/doc/ape

# Copy the test pfile so we can run tests later on, and the user can play with it to familiarize
# with the tools
mkdir -p ${PREFIX}/share/ape/ && cp -rf --dereference ape/src/test/unix-ref/ape_test.par ${PREFIX}/share/ape/
