<?php

function retrieve_user_data($con)
{
    // Check if the user is logged in via session
    if (isset($_SESSION['id'])) {
        $id = $_SESSION['id'];

        // Use a prepared statement to prevent SQL injection
        $stmt = $con->prepare("SELECT * FROM users WHERE id = ? LIMIT 1");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();

        // If a matching user is found, return their data as an associative array
        if ($result && $result->num_rows > 0) {
            return $result->fetch_assoc();
        }
    }

    // If no valid session/user found, redirect to login page
    header("Location: landing.php");
    die;
}

function generate_csrf_token()
{
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

function start_secure_session($timeout_duration = 7200) // Default timeout: 2 hours
{
    // Set secure cookie parameters before starting the session
    session_set_cookie_params([
        'secure' => true,          // Cookie only sent over HTTPS
        'httponly' => true,        // Prevent JS access to the cookie
        'samesite' => 'Strict'     // Helps mitigate CSRF attacks
    ]);
    session_start();

    // Check for session timeout
    if (isset($_SESSION['last_activity'])) {
        $elapsed_time = time() - $_SESSION['last_activity'];
        if ($elapsed_time > $timeout_duration) {
            // Session expired: destroy it
            session_unset();
            session_destroy();
            // Optional: redirect to login or landing page
            header("Location: landing.php");
            exit();
        }
    }

    // Update last activity time
    $_SESSION['last_activity'] = time();
}