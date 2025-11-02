<?php
include "functions.php";
start_secure_session();
$csrf_token = generate_csrf_token();
require_once __DIR__ . '/../private/connection.php';

if($_SERVER['REQUEST_METHOD'] == "POST"){
    //something was posted
    if (!isset($_POST['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) { 
    // Validate CSRF token
        die("Invalid CSRF token");
    }
    $user_name = $_POST['user_name'];
    $password = $_POST['password'];
    //check if user has entered something and that the username is not a number
    if(!empty($user_name) && !empty($password) && !is_numeric($user_name)){
        //read from database
        $query = "SELECT * FROM users WHERE user_name = ? LIMIT 1";
        $stmt = mysqli_prepare($con, $query);
        mysqli_stmt_bind_param($stmt, "s", $user_name);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);


        if($result)
        {
            if($result && mysqli_num_rows($result) > 0)
            {
                $user_data = mysqli_fetch_assoc($result);

                if(password_verify($password, $user_data['password']))
                {
                    session_regenerate_id(true); // Prevent session fixation
                    $_SESSION['id'] = $user_data['id'];
                    header('Location: index.php');
                    die();
                }
            }
        }
        echo "Wrong username or password!";
    }
    //if one of these conditions is not met, ask the user to enter some valid information
    else{
        echo "Please enter some valid information!";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>SWEPT AWAY - Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"> <!-- Adaptation pour mobile -->
    <link rel="stylesheet" href="style.css">
</head>
<body id="body">
    <div class="vertical-scanline"></div>
        <form method="post">
            <div class="aspect-wrapper">
                <div class="grid-wrapper">
                    <div class="grid-container">
                        <div class="grid-box titled" data-title="Log In" style="grid-column: 6 / 12; grid-row: 3 / 6;">
                            <H3>Username:</H3>
                            <input id="text" type="text" name="user_name"><br>
                            <H3>Password:</H3>
                            <input id="password" type="password" name="password"><br>
                            <!-- CSRF Token -->
                            <input type="hidden" name="csrf_token" value="<?= $csrf_token ?>">
                        </div>
                        <div class="grid-box full-button-preparation" style="grid-column: 6 / 12; grid-row: 6 / 7;">
                            <button class="full-button" type="submit">LOGIN</button>
                        </div>
                        <div class="grid-box full-button-preparation" style="grid-column: 6 / 12; grid-row: 7 / 8;"> <!-- Possible change to a button if needed for example have it take the user to a donation page */ -->
                            <button class="full-button" type="button" onclick="window.location.href='register.php'">REGISTER</button> <!--- type="button" ensures it doesnt just submit the form --->
                        </div>
                    </div>
                </div>
            </div>
        </form>
</body>
</html>






