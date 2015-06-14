This page describes how to run simulations for multipath TCP

## Quick Start ##

> ### Using sample script ###
> You can download the sample script from http://code.google.com/p/multipath-tcp/downloads/detail?name=mptcp-sample.tcl&can=2&q=#makechanges

> The sample script create 2 mptcp instances (sender and receiver) and 2 pairs of SackFullTcpAgent. In the configuration in the sample script, all connections should get almost the same amount of bandwidth after they reach equivalent state.

> If you run this script with the following command line, xgraph will display the simulation result.

> %**ns mptcp-sample.tcl**

> Also, since the script generates nam trace file, you can see the simulation result with nam by the following command line

> %**nam out.nam**


## How to parse mptcp traffic in trace files ##

> If you put the following line in your scripts, the trace module outputs mptcp information in trace files.
> > % _Trace set show\_tcphdr**2**_


> The mptcp traffic in trace files will be something like:

**- 0.130126 1 10 tcp 576 ------- 0 1.1 4.1 537 22 1 0x18 40 0 D 1073 537 536**

**r 0.161611 11 2 ack 40 ------- 0 5.1 2.1 1 37 1073 0x18 40 0 A 2145**


> The **D 1073 537 536** or **A 2145** is the mptcp option information. The **D** and **A** indicate the option types (**D** .. Data,   **A** ... DataAck,    **M** .. MP\_CAPABLE,   **J** .. Join)

> In case of Data Option, option fields represent **D "Data Seqnum" "Subflow Seqnum" "Data-level length"**

> In case of DataAck Option, option fields represent **A "Data Seqnum**


## Write your own scripts ##

TBD