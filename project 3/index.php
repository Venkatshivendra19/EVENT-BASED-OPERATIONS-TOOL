<?php
include './search.php';

// Create connection
$conn = mysqli_connect($host, $username, $password,$database,$port);

// Check connection
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

$query="select * FROM TRAPS";
$result=mysqli_query($conn,$query);

if(isset($_GET['submit']))
{
	$sql="CREATE TABLE if not exists ADDRESS (
	id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	IP VARCHAR(255) NOT NULL,
	PORT VARCHAR(255) NOT NULL,
	COMMUNITY VARCHAR(255)
	)";
	mysqli_query($conn, $sql) or die("table creation failed:" . mysqli_error($conn));


	$sql = "INSERT INTO ADDRESS (id, IP, PORT,COMMUNITY) VALUES ('1', '". $_GET["IP"] . "', '". $_GET["PORT"] . "', '". $_GET["COMMUNITY"] . "')
			on DUPLICATE KEY update IP='".$_GET["IP"]."', PORT='".$_GET["PORT"]."',COMMUNITY='".$_GET["COMMUNITY"]."'";
	mysqli_query($conn, $sql);
}
?>



<html>
	<body>
		<h3 style='text-align: center;'>ASSIGNMENT-3</h3>

</br>
</br>
</br>
<div style = "margin-left: 300px; float : left;">
	<table style = "text-align: left; " width="40%" border="1" cellpadding="1" cellspacing="1">				
		<tr>
		<th>FQDN</th>
		<th>new status</th>
		<th>current time</th>
		<th>old status</th>
		<th>previous time</th>
		</tr>

<?php
  if(mysqli_num_rows($result)>0)
{
while($row=mysqli_fetch_assoc($result))
{
?>


			
			<tr>
				<td>
				<?php echo $row['fqdn'];?>
				</td>
				<td>
				<?php echo $row['newstatus'];?>
				</td>
			
				<td>
				<?php echo $row['currenttime'];?>
				</td>
			
				<td>
				<?php echo $row['oldstatus'];?>
				</td>
			
				<td>
				<?php echo $row['previoustime'];?>
				</td>
			</tr>
<?php
}
}
?>
	</table>
</div>

<div style = "margin-left: 800px;">
	<table style = "text-align: left;" cellspacing="1" >	
	<form action="frontend.php">
	<tr><th>IP:</th><td> <input type="text" name="IP"><br></td></tr>
	<tr><th>PORT:</th><td> <input type="text" name="PORT"><br></td></tr>
	<tr><th>COMMUNITY:</th><td> <input type="text" name="COMMUNITY"><br></td></tr>
	</table>
	</br>
	<input type="submit" name=submit value="Submit">
</div>

</form>

</body>
</html>
