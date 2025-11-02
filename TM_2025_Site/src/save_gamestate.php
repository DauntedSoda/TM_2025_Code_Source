<?php
include "functions.php";
start_secure_session();
header('Content-Type: application/json');

include("connection.php");

// Check if the user is logged in
if (!isset($_SESSION['id'])) {
    echo json_encode(["success" => false, "message" => "Not logged in"]);
    exit;
}

$id = $_SESSION['id'];

// Read raw JSON input from HTTP body
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

$kill_count = isset($data['kill_count']) ? intval($data['kill_count']) : 0;
$inventory = isset($data['inventory']) ? json_encode($data['inventory']) : null;  // encode inventory array/object as JSON string
$position_x = isset($data['position_x']) ? floatval($data['position_x']) : null;
$position_y = isset($data['position_y']) ? floatval($data['position_y']) : null;
$last_total_kills = isset($data['last_total_kills']) ? intval($data['last_total_kills']) : 0;
$last_total_playtime = isset($data['last_total_playtime']) ? intval($data['last_total_playtime']) : 0;


try {
    // Get current high score
    $stmt = $con->prepare("SELECT highest_kill_game FROM users WHERE id = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        $current_high = intval($row["highest_kill_game"]);

        if ($kill_count > $current_high) {
            $update = $con->prepare("UPDATE users SET highest_kill_game = ?, last_inventory = ?, last_position_x = ?, last_position_y = ?, total_kills = ?, total_playtime = ? WHERE id = ?");
            $update->bind_param("isddiii", $kill_count, $inventory, $position_x, $position_y, $last_total_kills, $last_total_playtime, $id);
            $update->execute();
            echo json_encode(["success" => true, "message" => "New high score and game state saved"]);
        } else {
            $update = $con->prepare("UPDATE users SET last_inventory = ?, last_position_x = ?, last_position_y = ?, total_kills = ?, total_playtime = ? WHERE id = ?");
            $update->bind_param("sddiii", $inventory, $position_x, $position_y, $last_total_kills, $last_total_playtime, $id);
            $update->execute();
            echo json_encode(["success" => true, "message" => "Game state saved (no new high score)"]);
        }

    } else {
        echo json_encode(["success" => false, "message" => "User not found"]);
    }

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
}
// CSRF protection is not implemented yet on this endpoint.
// The main risk is that a user’s save data (kill count) could be altered via forged requests,
// allowing cheating but no direct account compromise.
// Could be added later if needed.