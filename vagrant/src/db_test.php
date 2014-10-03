<?php
//Create connection; Unsafe no pass
$con=mysqli_connect("localhost","root","","test");

//Check connection; No output is good
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
?>