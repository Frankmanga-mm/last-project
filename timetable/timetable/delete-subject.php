<?php
include 'db_connection.php';

// Check if the subject ID is provided in the URL
if (isset($_GET["id"])) {
    $subject_id = $_GET["id"];

    // Delete the subject from the database
    $conn->query("DELETE FROM subjects WHERE id = $subject_id");
    header("Location: view-subjects.php"); // Redirect to the subjects page after deleting
    exit();
} else {
    echo "Subject ID not provided.";
    exit();
}
?>
