<?php
include './search.php';

// Create connection
$conn = mysqli_connect($host, $username, $password,$database,$port);

// Check connection
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}
$sql="CREATE TABLE ADDRESS (
id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
IP VARCHAR(255) NOT NULL,
PORT VARCHAR(255) NOT NULL,
COMMUNITY VARCHAR(255)
)";
mysqli_query($conn, $sql);


$sql = "INSERT INTO ADDRESS (IP, PORT,COMMUNITY)
VALUES ('". $_GET["IP"] . "', '". $_GET["PORT"] . "', '". $_GET["COMMUNITY"] . "')";
mysqli_query($conn, $sql);
?>

