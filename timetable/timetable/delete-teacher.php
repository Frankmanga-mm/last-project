<?php
include 'db_connection.php';

// Check if the teacher ID is provided in the URL
if (isset($_GET["id"])) {
    $teacher_id = $_GET["id"];

    // Delete the teacher from the database
    $conn->query("DELETE FROM teachers WHERE id = $teacher_id");
    header("Location: view-teachers.php"); // Redirect to the teachers page after deleting
    exit();
} else {
    echo "Teacher ID not provided.";
    exit();
}
?>
