#Copyright (c) 1997 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $Header: /cvsroot/nsnam/ns-2/tcl/ex/wireless-mitf.tcl,v 1.2 2000/08/30 00:10:45 haoboy Exp $
#
# Simple demo script for the new APIs to support multi-interface for 
# wireless node.
#
# Define options
# Please note: 
# 1. you can still specify "channelType" in node-config right now:
# set val(chan)           Channel/WirelessChannel
# $ns_ node-config ...
#		 -channelType $val(chan)
#                  ...
# But we recommend you to use node-config in the way shown in this script
# for your future simulations.  
# 
# 2. Because the ad-hoc routing agents do not support multiple interfaces
#    currently, this script can't generate anything interesting if you config
#    the interfaces of node 1 and 2 on different channels
#   
#     --Xuan Chen, USC/ISI, July 21, 2000
#
set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             4                          ;# number of mobilenodes
#set val(rp)             DSDV                       ;# routing protocol
set val(rp)             DSR                       ;# routing protocol
set val(x)		300
set val(y)		300


#
# specify to print mptcp option information
#
Trace set show_tcphdr_ 2

# Initialize Global Variables
set ns_		[new Simulator]
set tracefd     [open out.tr w]
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

set namtrace [open out.nam w] 
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# Create God
create-god $val(nn)

# New API to config node: 
# 1. Create channel (or multiple-channels);
# 2. Specify channel in node-config (instead of channelType);
# 3. Create nodes for simulations.

# Create channel #1 and #2
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]

# Create node(0) "attached" to channel #1

# configure node, please note the change below.
$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-movementTrace OFF \
		-channel $chan_1_ 

set node_(0) [$ns_ node]
set node_(2) [$ns_ node]

# node_(1) can also be created with the same configuration, or with a different
# channel specified.
# Uncomment below two lines will create node_(1) with a different channel.
$ns_ node-config \
		 -channel $chan_2_ 
set node_(1) [$ns_ node]
set node_(3) [$ns_ node]

$node_(0) random-motion 0
$node_(1) random-motion 0
$node_(2) random-motion 0
$node_(3) random-motion 0

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 15
}

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$node_(0) set X_ 50.0
$node_(0) set Y_ 20.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 50.0
$node_(1) set Y_ 60.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 100.0
$node_(2) set Y_ 20.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 100.0
$node_(3) set Y_ 60.0
$node_(3) set Z_ 0.0

# Setup traffic flow between nodes
# Subflow TCP connections between node_(0) and node_(2)
# Subflow TCP connections between node_(1) and node_(3)

#
# prepare mptcp nodes
#
set n0 [$ns_ node]
$ns_ multihome-add-interface $n0 $node_(0)
$ns_ multihome-add-interface $n0 $node_(1)
$n0 set X_ 20.0
$n0 set Y_ 40.0
$n0 set Z_ 0.0
$n0 color red
$ns_ initial_node_pos $n0 20

# Setup traffic flow between nodes

set n1 [$ns_ node]
$ns_ multihome-add-interface $n1 $node_(2)
$ns_ multihome-add-interface $n1 $node_(3)
$n1 set X_ 130.0
$n1 set Y_ 40.0
$n1 set Z_ 0.0
$n1 color blue
$ns_ initial_node_pos $n1 20

#
# create mptcp sender
#
set tcp0 [new Agent/TCP/FullTcp/Sack/Multipath]
$tcp0 set window_ 100 
$ns_ attach-agent $node_(0) $tcp0
set tcp1 [new Agent/TCP/FullTcp/Sack/Multipath]
$tcp1 set window_ 100 
$ns_ attach-agent $node_(1) $tcp1
set mptcp [new Agent/MPTCP]
$mptcp attach-tcp $tcp0
$mptcp attach-tcp $tcp1
$ns_ multihome-attach-agent $n0 $mptcp
set ftp [new Application/FTP]
$ftp attach-agent $mptcp

#
# create mptcp receiver
#
set mptcpsink [new Agent/MPTCP]
set sink0 [new Agent/TCP/FullTcp/Sack/Multipath]
$ns_ attach-agent $node_(2) $sink0 
set sink1 [new Agent/TCP/FullTcp/Sack/Multipath]
$ns_ attach-agent $node_(3) $sink1 
$mptcpsink attach-tcp $sink0
$mptcpsink attach-tcp $sink1
$ns_ multihome-attach-agent $n1 $mptcpsink
$ns_ connect $tcp0 $sink0
$ns_ connect $tcp1 $sink1
$ns_ multihome-connect $mptcp $mptcpsink
$mptcpsink listen

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 300.0 "$node_($i) reset";
}
$ns_ at 300.01 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at 300.02 "stop"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

proc init_nodes {} {
	global n0 n1 node_
	$n0 color blue
	$n1 color red
	$n1 setdest 230 240 10
	$node_(2) setdest 200 220 10
	$node_(3) setdest 200 260 10
}

proc reset_nodes {} {
	global n0 n1 node_
	$n1 setdest 130 40 5
	$node_(2) setdest 100 20 5
	$node_(3) setdest 100 60 5
}

puts "Starting Simulation..."
$ns_ at 0 "init_nodes"
$ns_ at 150 "reset_nodes"
$ns_ at 0.1 "$ftp start" 
$ns_ run
