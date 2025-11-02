<?php
include "functions.php";
start_secure_session();

if (isset($_SESSION['id'])) {
    echo "Logged in as user ID: " . $_SESSION['id'];
} else {
    echo "Not logged in.";
}