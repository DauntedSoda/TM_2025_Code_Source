<?php

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);  //Afficher les erreurs silencieuses 

$dbhost = "mysql_db";  
$dbuser = "root";       // MySQL root user
$dbpass = "root";       // MySQL root password
$dbname = "mydb";       // Nom de base de donnee comme defini dans docker-compose.yml

if (!$con = mysqli_connect($dbhost, $dbuser, $dbpass, $dbname)) {
    die("Failed to connect!");
}