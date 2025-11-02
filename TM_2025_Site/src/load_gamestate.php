<?php
include "functions.php";
start_secure_session();
require_once __DIR__ . '/../private/connection.php';

header("Content-Type: application/json");

if (!isset($_SESSION["id"])) {
    echo json_encode(["success" => false, "message" => "User not logged in"]);
    exit;
}

$id = $_SESSION["id"];

try {
    $stmt = $con->prepare("SELECT last_inventory, last_position_x, last_position_y, total_kills, total_playtime FROM users WHERE id = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        echo json_encode([
            "success" => true,
            "inventory" => json_decode($row["last_inventory"], true),
            "position_x" => $row["last_position_x"],
            "position_y" => $row["last_position_y"],
            "last_total_kills" => $row["total_kills"],
            "last_total_playtime" => $row["total_playtime"]
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "User not found"]);
    }

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
}
