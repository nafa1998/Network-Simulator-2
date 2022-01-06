set val(stop) 10.0 ; #time of simulation end
#Create a ns simulator
set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

#Open the NS trace file 
set tracefile [open p1.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open p1.nam w]
$ns namtrace-all $namfile


#Create 5 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

#Create labels for nodes
$n0 label "Tcp Source"
$n3 label "Tcp_Destination"
$n1 label "UdpSource "
$n2 label "Udp Destination"

#Give shapes to nodes
$n0 shape square
$n3 shape square
$n4 shape circle
$n1 shape hexagon
$n2 shape hexagon
#Give colors to nodes
$n0 color green
$n3 color red
$n1 color green
$n2 color red
$n4 color black
#Create links between nodes
$ns duplex-link $n0 $n4 100.0Mb 40ms DropTail
$ns queue-limit $n0 $n4 5 ; # default queue limit is 50

$ns duplex-link $n4 $n3 100.0Mb 40ms DropTail
$ns queue-limit $n4 $n3 5

$ns duplex-link $n1 $n4 100.0Mb 40ms DropTail
$ns queue-limit $n1 $n4 5

$ns duplex-link $n4 $n2 100.0Mb 40ms DropTail
$ns queue-limit $n4 $n2 5

$ns duplex-link-op $n4 $n2 queuePos 0.5 ;# give reading when queue content is 50%
$ns duplex-link-op $n4 $n0 queuePos 0.5

#Give node position (for NAM)
$ns duplex-link-op $n4 $n0 orient left-down
$ns duplex-link-op $n1 $n4 orient left-up
$ns duplex-link-op $n3 $n4 orient left-down
$ns duplex-link-op $n2 $n4 orient right-down

#Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink3 [new Agent/TCPSink]
$ns attach-agent $n3 $sink3
$ns connect $tcp0 $sink3
$tcp0 set packetSize_ 1000

#Setup a UDP connection
set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1
set null2 [new Agent/Null]
$ns attach-agent $n2 $null2
$ns connect $udp1 $null2
$udp1 set packetSize_ 1000

#Assign flow-id
$tcp0 set fid_ 1
$udp1 set fid_ 2



#Setup a CBR Application over TCP connection
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $tcp0
$cbr0 set packetSize_ 1000
$cbr0 set rate_ 3.0Mb
$cbr0 set random_ null
$ns at 0.01 "$cbr0 start"
$ns at 9.9 "$cbr0 stop"

#Setup a CBR Application over UDP connection
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set packetSize_ 1000
$cbr1 set rate_ 2.0Mb
$cbr1 set random_ null
$ns at 0.1 "$cbr1 start"
$ns at 9.0 "$cbr1 stop"

#Define a 'finish' procedure
proc finish {} {
global ns tracefile namfile
    $ns flush-trace
close $tracefile
close $namfile
exec nam p1.nam &
exit 0
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
