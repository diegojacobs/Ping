use Socket;
use Sys::Hostname;
use Time::HiRes qw( gettimeofday tv_interval);
$hostIp = $ARGV[0];
my $id = 0;

main();

sub main { 
    socket(SOCKET , AF_INET, SOCK_RAW, 1) or die $!;
     
    my $senderIp = inet_ntoa((gethostbyname(hostname))[4]);
    my $senderPort = 1;

    my $receiverIp = (gethostbyname($hostIp))[4];
    my $receiverPort = 1;
    #paquete a enviar
    my $packet = headers($senderIp, $senderPort, $receiverIp, $receiverPort);
    my $destination = pack('Sna4x8', AF_INET, $receiverPort, $receiverIp);
    #cantidad de bytes mandados
    my $bytesSize = send(SOCKET , $packet , 0 , $destination) or die $!;

    my $ip_host = "";
    if (length(inet_aton($hostIp)) != 0) {
        $ip_host = inet_ntoa(inet_aton($hostIp));
    }
      
    print "PING " . $hostIp . " (" . $ip_host . ")" . ": " . $bytesSize . " bytes of data \n";
    
    my $cont = 0;
    while ($cont < 10) {
        my $timer = tv_interval ( $t0, [gettimeofday]);
        
        my $buf = "";
        
        #saves the data received
        my $received_bytes = sysread(SOCKET, $buf, 1024, 0);    
        
        $icmpHeader = $buf;
        @array = unpack("ccnSs", $buf);
    
        my $type = $array[10];
        print $type;
        
        my $code = $array[11];
        print $code;
        my $verify_id = $array[13];
        print $verify_id;

        #check valid request
        if ($verify_id == $id and $type == 0 and $code == 0) {

            my $now_time = tv_interval ( $t0, [gettimeofday]) - $timer;
            my $RRT = substr($now_time*1000, 0, 5);
            my $RRT2 = $RRT/2;
            print $received_bytes . " bytes from " . " (".$ip_host. ") " . " icmp_seq=" . $cont . " time=" . $RRT2 . " ms \n";
            
            $cont = $cont + 1;
            sleep(1);
        }
    }
} 
sub headers {
    local($src_host , $src_port , $hostIp , $dst_port) = @_;
    
    my $id = int(rand(10000));
    my $icmpHeader = pack('ccSSs', 8, 0,0, $id, 1);
    my $data = "My Ping Final Test v1.0";
    my $checksum = checksum($icmp_header . $data);

    my $icmpHeader = pack('ccnSs', 8, 0, ($checksum), $id, 1);
    
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