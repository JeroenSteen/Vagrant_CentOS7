<?php
//Create connection with Root pass
$con=mysqli_connect("localhost","root","secret","test");

//Check connection; No output is good
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
?>