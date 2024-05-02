<?php
include 'db_connection.php';

// Check if the course ID is provided in the URL
if (isset($_GET["id"])) {
    $course_id = $_GET["id"];

    // Delete the course from the database
    $conn->query("DELETE FROM courses WHERE id = $course_id");
    header("Location: view-courses.php"); // Redirect to the courses page after deleting
    exit();
} else {
    echo "Course ID not provided.";
    exit();
}
?>
