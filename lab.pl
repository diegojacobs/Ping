use Socket;
use Sys::Hostname;

$dst_host = $ARGV[0];

main();

sub main { 
    socket(SOCKET , AF_INET, SOCK_RAW, 1) or die $!;
     
    #set IP_HDRINCL to 1, this is necessary when the above protocol is something other than IPPROTO_RAW
    my $srcHost = inet_ntoa((gethostbyname(hostname))[4]);
    my $srcPort = 1;

    my $dstHost = (gethostbyname($dst_host))[4];
    my $dstPort = 1;

    my $packet = headers($srcHost, $srcPort, $dstHost, $dstPort);
     
    my $destination = pack('Sna4x8', AF_INET, $dstPort, $dstHost);

    my $bytesSent = send(SOCKET , $packet , 0 , $destination) or die $!;
    print "PING " . $dst_host . " (" . $dst_host . ")" . ": " . $bytesSent . " bytes of data \n";
    
}
 
sub headers {
    local($src_host , $src_port , $dst_host , $dst_port) = @_;
    
    my $id = int(rand(1000));
    
    my $icmpHeader = pack('ccSSs', 8, 0,0, $id, 1);
    my $data = "My Ping Test v1.0";
    my $myChecksum = checksum($icmp_header . $data);
    $icmpHeader = pack('ccnSs', 8, 0, ($myChecksum), $id, 1);

    my $packet =  $icmpHeader . $data;
     
    return $packet;
}
 
#para el calculo del checksum podrian usar una funcion como la siguiente
sub checksum {
    my $msg = shift;
    my $length = length($msg);
    my $numShorts = $length/2;
    my $sum = 0;

    foreach (unpack("n$numShorts", $msg)) {
       $sum += $_;
    }

    $sum += unpack("C", substr($msg, $length - 1, 1)) if $length % 2;
    $sum = ($sum >> 16) + ($sum & 0xffff);
    return(~(($sum >> 16) + $sum) & 0xffff);
} 