#Declare New Simulasi 
set ns [new Simulator]
$ns color 1 blue
$ns color 2 red

#seting output 
set nm [open TcpVegas-DropTail.nam w]
$ns namtrace-all $nm
set nt [open TcpVegas-DropTail.tr w]
$ns trace-all $nt

#Setting Node 
#Node Sender 
set n0 [$ns node]
set n1 [$ns node]

#router 
set n2 [$ns node]
set n3 [$ns node]

#Node Receiver
set n4 [$ns node]
set n5 [$ns node]

#Node Pengirim 
$ns duplex-link $n0 $n2 12Mb 10ms DropTail
$ns duplex-link $n1 $n2 12Mb 10ms DropTail

#Router 
$ns duplex-link $n2 $n3 12Mb 10ms DropTail

#Node penerima 
$ns duplex-link $n3 $n4 12Mb 10ms DropTail
$ns duplex-link $n3 $n5 12Mb 10ms DropTail

#Setting panjang antrian (parameter buffer yang akan di ubah2 [2,3,4,5,6,7,8,9,10,11,12,13,14,15]
$ns queue-limit $n2 $n3 50

#setting posisi 
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down
$ns duplex-link-op $n2 $n3 queuePos 0.5

#setting antrian DropTail
set redq [[$ns link $n2 $n3] queue]
#set tchan_ [open all.q w]
$redq set bytes_ false
$redq set queue_in_bytes_ false
$redq trace curq_
$redq trace ave_
#$redq attach $tchan_
$redq set thresh_ 10
$redq set maxthresh_ 60
$redq set q_weight_ 0.002
$redq set linterm_ 10

#tcp
set tcp [new Agent/TCP/Vegas]
$tcp set class_ 1
$tcp set window_ 50 #default:20
$tcp set packetSize_ 1000 
$tcp set ssthresh_ 64 
$ns attach-agent $n0 $tcp


set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$tcp attach $nt
$tcp tracevar cwnd_
$tcp tracevar ssthresh_
#set UDP and Null and CBR Application
set udp [new Agent/UDP]
$udp set class_ 2
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n5 $null
$ns connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
#$cbr set packetSize_ 1000 #default:210
$cbr set rate_ 300kb #default:448kb
$cbr set random_ false

proc cwnd_trace {tcpSource outfile} {
global ns
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $outfile "$now $cwnd"
$ns at [expr $now+0.1] "cwnd_trace $tcpSource $outfile"
}


proc finish {} {
global ns nm nt
$ns flush-trace

exit 0

}
$ns at 0.1 "$ftp start"
$ns at 500.0 "$ftp stop"
$ns at 0.5 "$cbr start"
$ns at 500 "$cbr stop"
$ns at 500.1 "finish"

#menjalankan simulator
$ns run
