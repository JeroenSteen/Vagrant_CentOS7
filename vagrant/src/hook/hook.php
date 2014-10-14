<?php
#Variable for Payload; JSON data
$payload = "";

#JSON data is received
if(isset($_POST["payload"])){
	#Decode JSON for Use with PHP
	$payload = json_decode($_POST["payload"]);
} else {
	#No JSON data received
	return false;
}

#Get Repo
$repo	= $payload->repository;
#Get URL of Repo
$url	= $repo->absolute_url;
#Get Code from Repo
exec("git init && git remote add origin git@bitbucket.org:".$url.".git && git pull origin master");
#Register Event to Logfile
file_put_contents("bb_deploy.log", "Last run on: ".date('d/m/Y h:i:sa'), FILE_APPEND);