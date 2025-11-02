<?php
include "functions.php";
start_secure_session();
$csrf_token = generate_csrf_token();
include "connection.php";

$error = "";
$highlight = "";

if ($_SERVER['REQUEST_METHOD'] === "POST") {
    if (!isset($_POST['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) { 
    // Validate CSRF token
        die("Invalid CSRF token");
    }
    $user_name = trim($_POST['user_name']);
    $password = $_POST['password'];

    // Validation
    if (strlen($user_name) < 3 || is_numeric($user_name)) {
        $error = "Username too short or invalid.";
        $highlight = "user_name";
    } elseif (empty($password)) {
        $error = "Password cannot be empty.";
        $highlight = "password";
    } else {
        // Check if username already exists
        $stmt = $con->prepare("SELECT 1 FROM users WHERE user_name = ? LIMIT 1");
        $stmt->bind_param("s", $user_name);
        $stmt->execute();
        $stmt->store_result();

        if ($stmt->num_rows > 0) {
            $error = "This username is already in use.";
            $highlight = "user_name";
        } else {
            // Hash password and insert user
            $hashed_password = password_hash($password, PASSWORD_DEFAULT);

            $insert = $con->prepare("INSERT INTO users (user_name, password) VALUES (?, ?)");
            $insert->bind_param("ss", $user_name, $hashed_password);
            $insert->execute();

            header("Location: login.php");
            exit;
        }
    }
}
?>


<!DOCTYPE html>
<html>
<head>
    <title>SWEPT AWAY - Register</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">  <!-- Adaptation aux écrans mobiles --->
    <link rel="stylesheet" href="style.css">
</head>
<body id="body">
    <div class="vertical-scanline"></div>
    <form method="post">
        <div class="aspect-wrapper">
            <div class="grid-wrapper">
                <div class="grid-container">
                    <div class="grid-box titled" data-title="Register" style="grid-column: 6 / 12; grid-row: 3 / 6;">
                        <H3>Username:</H3>
                        <input id="text" type="text" name="user_name" class="<?php echo $highlight === 'user_name' ? 'error' : ''; ?>"><br>
                        <H3>Password:</H3>
                        <input id="password" type="password" name="password" class="<?php echo $highlight === 'password' ? 'error' : ''; ?>"><br>
                        <?php if (!empty($error)): ?>
                            <div class="error-text"><?php echo $error; ?></div>
                        <?php endif; ?>
                        <!-- CSRF Token -->
                        <input type="hidden" name="csrf_token" value="<?= $csrf_token ?>">
                    </div>
                    <div class="grid-box full-button-preparation" style="grid-column: 6 / 12; grid-row: 6 / 7;">
                        <button class="full-button" type="submit">REGISTER</button>
                    </div>
                    <div class="grid-box full-button-preparation" style="grid-column: 6 / 12; grid-row: 7 / 8;">
                        <button class="full-button" type="button" onclick="window.location.href='login.php'">LOGIN</button> <!-- type="button" ensures it doesnt just submit the form -->
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
