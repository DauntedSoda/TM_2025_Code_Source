<?php
include "functions.php";
start_secure_session();
include "connection.php";

$user_data = retrieve_user_data($con);
$id = $_SESSION['id'];

// Fetch top 20 scores
$top_stmt = $con->prepare("SELECT user_name, highest_kill_game FROM users ORDER BY highest_kill_game DESC LIMIT 20"); //Change the limit to control how many of the top players are shown
$top_stmt->execute();
$top_result = $top_stmt->get_result();

$top_scores = [];
while ($row = $top_result->fetch_assoc()) {
    $top_scores[] = $row;
}
// Fetch top 10 kills
$top_stmt = $con->prepare("SELECT user_name, total_kills FROM users ORDER BY total_kills DESC LIMIT 10"); //Change the limit to control how many of the top players are shown
$top_stmt->execute();
$top_result = $top_stmt->get_result();

$top_kills = [];
while ($row = $top_result->fetch_assoc()) {
    $top_kills[] = $row;
}
// Fetch top 10 times
$top_stmt = $con->prepare("SELECT user_name, total_playtime FROM users ORDER BY total_playtime DESC LIMIT 10"); //Change the limit to control how many of the top players are shown
$top_stmt->execute();
$top_result = $top_stmt->get_result();

$top_time = [];
while ($row = $top_result->fetch_assoc()) {
    $top_time[] = $row;
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>SWEPT AWAY - Home</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">  <!-- Adaptation aux écrans mobiles --->
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="vertical-scanline"></div>
    <div class="aspect-wrapper">
        <div class="grid-wrapper">
            <div class="grid-container">
                <div class="grid-box" style="grid-column: 1 / 10; grid-row: 1 / 5;">
                    <img src="ascii_image.png" alt="ASCII Art" class="ascii-image">
                </div>
                <div class="grid-box titled" data-title="Most Kills" style="grid-column: 1 / 5; grid-row: 5 / 10;">
                    <table>
                        <tr><th>Rank</th><th>Username</th><th>Total Kills</th></tr>
                        <?php foreach ($top_kills as $index => $player): ?>
                            <tr>
                                <td><?= $index + 1 ?></td>
                                <td><?= htmlspecialchars($player['user_name']) ?></td> <!--- Escape HTML to prevent XSS especially important as this is visible to all players --->
                                <td><?= intval($player['total_kills']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </table>
                </div>
                <div class="grid-box titled" data-title="Most Playtime" style="grid-column: 5 / 10; grid-row: 5 / 10;">
                    <table>
                        <tr><th>Rank</th><th>Username</th><th>Total Playtime [s]</th></tr>
                        <?php foreach ($top_time as $index => $player): ?>
                            <tr>
                                <td><?= $index + 1 ?></td>
                                <td><?= htmlspecialchars($player['user_name']) ?></td> <!--- Escape HTML to prevent XSS especially important as this is visible to all players --->
                                <td><?= intval($player['total_playtime']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </table>
                </div>
                <div class="grid-box titled" data-title="Highscore" style="grid-column: 10 / 16; grid-row: 1 / 8;">
                    <table>
                        <tr><th>Rank</th><th>Username</th><th>Highscore</th></tr>
                        <?php foreach ($top_scores as $index => $player): ?>
                            <tr>
                                <td><?= $index + 1 ?></td>
                                <td><?= htmlspecialchars($player['user_name']) ?></td> <!--- Escape HTML to prevent XSS especially important as this is visible to all players --->
                                <td><?= intval($player['highest_kill_game']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </table>
                </div>
                <div class="grid-box titled" data-title="Stats" style="grid-column: 10 / 16; grid-row: 8 / 10;">
                    <p><strong>Username:</strong> <span class="username"><?= htmlspecialchars($user_data['user_name']) ?></span></p>
                    <p><strong>Highest Kill Game:</strong> <?= intval($user_data['highest_kill_game']) ?></p>
                    <p><strong>Total Kills:</strong> <?= intval($user_data['total_kills']) ?></p>
                    <p><strong>Total Playtime [s]:</strong> <?= intval($user_data['total_playtime']) ?></p>
                </div>
                <div class="grid-box full-button-preparation vertical-text " style="grid-column: 16 / 17; grid-row: 1 / 4;">
                    <button class="full-button" onclick="window.location.href='play.php'">PLAY</button>
                </div>
                <div class="grid-box full-button-preparation vertical-text" style="grid-column: 16 / 17; grid-row: 4 / 8;">
                    <button class="full-button" onclick="window.location.href='logout.php'">LOGOUT</button>
                </div>
                <div class="grid-box full-button-preparation big-red-button" style="grid-column: 16 / 17; grid-row: 8 / 10;"> <!-- Possible change to a button if needed for example have it take the user to a donation page */ -->
                    CAUTION
                </div>
            </div>
        </div>
    </div>
</body>
</html>