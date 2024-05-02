<?php
include 'db_connection.php';

// Check if the timetable ID is provided in the URL
if (isset($_GET["id"])) {
    $timetable_id = $_GET["id"];

    // Delete the timetable entry from the database
    $conn->query("DELETE FROM timetable WHERE id = $timetable_id");
    header("Location: view-timetable.php"); // Redirect to the timetable page after deleting
    exit();
} else {
    echo "Timetable ID not provided.";
    exit();
}
?>
