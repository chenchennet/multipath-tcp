Please do the following step to build the ns-2 with this code.

Note: We recommend to use ns-2.34 and haven't tested other versions.

## build from svn code ##

  * Download ns-2.34 code from http://www.isi.edu/nsnam/ns/ and extract it
  * Checkout the mptcp code from https://code.google.com/p/multipath-tcp/source/checkout
  * Merge ns-2.34 directory in the mptcp code into the original ns-2.34 directories by doing something like:
> > %cp -r multipath-tcp/ns-2.34/`*` ns-allinone-2.34/ns-2.34/`*`
  * build ns-2.34 as usual

## build from patch file ##

  * Download ns-2.34 code from http://www.isi.edu/nsnam/ns/ and extract it
  * Download the mptcp patch from https://code.google.com/p/multipath-tcp/downloads/detail?name=mptcp.patch.20100512&can=2&q=#makechanges
  * goto ns-2.34 directory and run the following command to apply the patch.
> > %patch -p1 < mptcp.patch.20100810.patch
  * build ns-2.34 as usual