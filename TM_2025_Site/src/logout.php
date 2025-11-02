<?php
include "functions.php";
start_secure_session();

// Clear all session variables
$_SESSION = [];

// Destroy the session completely
session_unset();
session_destroy();

// Redirect to login page
header("Location: landing.php");
exit;
?>
