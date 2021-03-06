#!/usr/bin/perl
use Net::SNMP;
use DBI;
use DBD::mysql;
use Data::Dumper qw(Dumper);
use Cwd 'abs_path';
my $abs_path = abs_path(__FILE__);
@path=split '/',$abs_path;

splice @path,-2;
push (@path,"db.conf");
$actualpath=join('/',@path);
require "$actualpath";

$dbh = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port", $username,$password);

$sql="CREATE TABLE IF NOT EXISTS TRAPS (
id int(30) NOT NULL primary key auto_increment,
 fqdn varchar(255) NOT NULL ,
 newstatus int(30) NOT NULL,
 currenttime varchar(255) NOT NULL,
 oldstatus varchar(255) NOT NULL,
 previoustime varchar(255) NOT NULL,
 UNIQUE KEY(fqdn)
 				 ) ";
$sth =$dbh->prepare($sql);

$sth->execute();
$sth->finish();

my $TRAP_FILE = "/home/anm/Desktop/snmp3.txt";

$fqdn;
$status;
open (TRAPFILE, ">> $TRAP_FILE");
#print TRAPFILE $abs_path;
while(<STDIN>)
{
#chomp($_);
my ($a,$b)=split(' ', $_);
print "$a    $b";
if($a eq 'iso.3.6.1.4.1.41717.10.1')
{
my ($p1, $p2, $p3)=split('"', $b);
$fqdn = $p2;
print TRAPFILE "$fqdn \n";

}
if($a eq 'iso.3.6.1.4.1.41717.10.2')
{
$status=$b;
print (TRAPFILE "$status \n");
}

}


#$status=2;
#$fqdn='pine';

if(($fqdn ne '') && ($status ne ''))
{
#print (TRAPFILE "$fqdn, $status");
my $time = time();
$dbh->do("insert into TRAPS  (fqdn,newstatus, oldstatus , currenttime, previoustime) values ('$fqdn' , '$status' , '0' , '" . $time ."', '0') 
		ON DUPLICATE KEY UPDATE previoustime = TRAPS.currenttime, currenttime = '$time', oldstatus=TRAPS.newstatus,newstatus='$status'") or die "Unable to connect: $DBI::errstr\n";

$oid_danger='.1.3.6.1.4.1.41717.30.';
$oid_fail='1.3.6.1.4.1.41717.20.';


if($status > 1)
{
$query="select * from ADDRESS";
$query_han=$dbh->prepare($query);
$query_han->execute();
if(@row=$query_han->fetchrow()){
($session, $error) = Net::SNMP->session(
         -hostname    => $row[1],
         -port        => $row[2], 
	 -community   => $row[3],
	 
           );

if (!defined $session) {
      printf "ERROR1: %s.\n", $session->error();
      $session->close();
}
}
#print Dumper $session;
my @oids;
my $i=1;
#DANGER
	if($status == 2)
	{
#print TRAPFILE "HAHAHAHHAHA";
	my $hash = $dbh->selectall_hashref("select *from TRAPS where newstatus='2'",'fqdn');
 
		if((my $count = (keys %$hash)) >= 2)
		{
			       foreach((keys %$hash))
				{
		push @oids,$oid_danger.$i++,OCTET_STRING,$_,$oid_danger.$i++,UNSIGNED32,$time,$oid_danger.$i++,INTEGER,$hash->{$_}{oldstatus},$oid_danger.$i++,UNSIGNED32,$hash->{$_}{previoustime};
				 # print(TRAPFILE "@oids");
       
					}
					
	}
}
#FAIL	
if($status == 3)
	{
my $hash = $dbh->selectall_hashref("select *from TRAPS where fqdn='$fqdn'",'fqdn');
	push @oids,$oid_fail.$i++,OCTET_STRING,$fqdn,$oid_fail.$i++,UNSIGNED32,$time,$oid_fail.$i++,INTEGER,$hash->{$fqdn}{oldstatus},$oid_fail.$i++,UNSIGNED32,$hash->{$fqdn}{previoustime};	

print(TRAPFILE "@oids");
	}


if(@oids)
{

	$result = $session->trap(
							 -enterprise      => '1.3.6.1.4.1',
							  -agentaddr       => '127.0.0.1',
							  -varbindlist      => \@oids,
						       );

 if (!defined $result) {
      printf "ERROR: %s.\n", $session->error();
      $session->close();
						}

}


}
 
}

close(TRAPFILE);
