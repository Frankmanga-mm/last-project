<?php
include 'db_connection.php';

// Check if the venue ID is provided in the URL
if (isset($_GET["id"])) {
    $venue_id = $_GET["id"];

    // Delete the venue from the database
    $conn->query("DELETE FROM venues WHERE id = $venue_id");
    header("Location: view-venues.php"); // Redirect to the venues page after deleting
    exit();
} else {
    echo "Venue ID not provided.";
    exit();
}
?>
