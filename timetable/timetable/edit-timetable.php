<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Arusha Technical College Timetable</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">
    <style>
        body {
            margin: 0;
            padding: 0;
            overflow-x: hidden; /* Hide horizontal scrollbar */
        }

        .top-bar {
            background-color: #353535;
            padding: 10px;
            text-align: center;
            position: fixed;
            width: 100%;
            z-index: 1000;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo-container {
            margin-right: 10px; /* Add some margin to the right of the logo */
        }

        .title-container {
            flex-grow: 1; /* Allow the title to take up remaining space */
            text-align: center;
            color: white;
        }

        .logo {
            max-width: 100px;
            height: auto;
        }

        .side-bar {
            background-color: black;
            height: 100vh;
            width: 200px;
            position: fixed;
            top: 60px; /* Set to the height of the top bar */
            left: 0;
            padding-top: 30px; /* Adjust top padding to align links with top bar */
            margin-bottom: 30px;
        }

        .side-bar a {
            display: block;
            padding: 10px;
            color: white;
            text-decoration: none;
            margin-bottom: 10px; /* Add margin between links */
        }

        .content {
            margin-left: 200px; /* Adjust based on side bar width */
            padding: 20px;
            transition: margin-left 0.3s; /* Add smooth transition effect */
            background-color: white; /* Add white background to content area */
        }
    </style>
</head>
<body>

<!-- Top Bar -->
<div class="top-bar">
    <div class="logo-container">
        <img class="logo" src="images/atclogo.jfif" alt="Logo" width="30" height="100">
    </div>
    <div class="title-container">
        <h2>Arusha Technical College</h2>
    </div>
</div>

<!-- Side Bar -->
<div class="side-bar">
    <a href="view-timetable.php">View Timetable</a>
    <a href="add-timetable.php">Add Timetable</a>
    <a href="view-courses.php">View Courses</a>
    <a href="add-course.php">Add Course</a>
    <a href="view-venues.php">View Venues</a>
    <a href="add-venue.php">Add Venue</a>
    <a href="view-teachers.php">View Lecturers</a>
    <a href="add-teacher.php">Add Lecturer</a>
    <a href="add-subject.php">Add Modules</a>
    <a href="view-subjects.php">View Modules</a>
    <a href="free-venue.php">Free Venue</a>

    <!-- Add more links for other pages as needed -->
</div>

<!-- Content Area -->
<?php
include 'db_connection.php';

// Check if the form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Sanitize and get form data
    $timetable_id = sanitizeInput($_POST["timetable_id"]);
    $new_course_id = sanitizeInput($_POST["new_course_id"]);
    $new_level = sanitizeInput($_POST["new_level"]);
    $new_subject_id = sanitizeInput($_POST["new_subject_id"]);
    $new_venue_id = sanitizeInput($_POST["new_venue_id"]);
    $new_teacher_id = sanitizeInput($_POST["new_teacher_id"]);
    $new_day = sanitizeInput($_POST["new_day"]);
    $new_time_start = sanitizeInput($_POST["new_time_start"]);
    $new_time_end = sanitizeInput($_POST["new_time_end"]);

    // Check for empty fields
    if (empty($new_course_id) || empty($new_level) || empty($new_subject_id) || empty($new_venue_id) || empty($new_teacher_id) || empty($new_day) || empty($new_time_start) || empty($new_time_end)) {
        $errorMsg = '<div class="alert alert-danger" role="alert">Please fill in all fields.</div>';
    } else {
        // Update the timetable entry
        $conn->query("UPDATE timetable SET course = '$new_course_id', level = '$new_level', subject = '$new_subject_id', venue = '$new_venue_id', teacher= '$new_teacher_id', day = '$new_day', time_start = '$new_time_start', time_end = '$new_time_end' WHERE id = $timetable_id");
        header("Location: view-timetable.php"); // Redirect to the timetable page after updating
        exit();
    }
}

// Check if the timetable ID is provided in the URL
if (isset($_GET["id"])) {
    $timetable_id = sanitizeInput($_GET["id"]);

    // Retrieve the timetable entry information
    $result = $conn->query("SELECT * FROM timetable WHERE id = $timetable_id");

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $course_id = $row["course"];
        $level = $row["level"];
        $subject_id = $row["subject"];
        $venue_id = $row["venue"];
        $teacher_id = $row["teacher"];
        $day = $row["day"];
        $time_start = $row["time_start"];
        $time_end = $row["time_end"];
    } else {
        echo "Timetable entry not found.";
        exit();
    }
} else {
    echo "Timetable ID not provided.";
    exit();
}

function sanitizeInput($input)
{
    global $conn;
    return mysqli_real_escape_string($conn, htmlspecialchars(strip_tags(trim($input))));
}

// Fetch available courses, venues, teachers, and days
$coursesResult = $conn->query("SELECT DISTINCT name FROM courses");
$venuesResult = $conn->query("SELECT DISTINCT name FROM venues");
$teachersResult = $conn->query("SELECT DISTINCT name FROM teachers");
$days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
$levelsResult = $conn->query("SELECT DISTINCT level FROM courses");
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Timetable Entry</title>
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h2>Edit Timetable Entry</h2>
        <?php echo isset($errorMsg) ? $errorMsg : ''; ?>
        <form action="" method="post">
            <input type="hidden" name="timetable_id" value="<?php echo $timetable_id; ?>">
            <div class="form-group">
                <label for="new_course_id">New Course:</label>
                <select class="form-control" id="new_course_id" name="new_course_id" required>
                    <?php
                    while ($courseRow = $coursesResult->fetch_assoc()) {
                        $selected = ($courseRow['name'] == $course_id) ? 'selected' : '';
                        echo "<option value='{$courseRow['name']}' $selected>{$courseRow['name']}</option>";
                    }
                    ?>
                </select>
            </div>
            <div class="form-group">
                <label for="new_level">New Level:</label>
                <select class="form-control" id="new_level" name="new_level" required>
                    <?php
                    // Reset the pointer to the beginning of the levels result set
                    $levelsResult->data_seek(0);

                    while ($levelRow = $levelsResult->fetch_assoc()) {
                        $selected = ($levelRow['level'] == $level) ? 'selected' : '';
                        echo "<option $selected>{$levelRow['level']}</option>";
                    }
                    ?>
                </select>
            </div>
            <div class="form-group">
                <label for="new_subject_id">New Subject:</label>
                <input type="text" class="form-control" id="new_subject_id" name="new_subject_id" value="<?php echo $subject_id; ?>">
            </div>
            <div class="form-group">
                <label for="new_venue_id">New Venue:</label>
                <select class="form-control" id="new_venue_id" name="new_venue_id" required>
                    <?php
                    while ($venueRow = $venuesResult->fetch_assoc()) {
                        $selected = ($venueRow['name'] == $venue_id) ? 'selected' : '';
                        echo "<option value='{$venueRow['name']}' $selected>{$venueRow['name']}</option>";
                    }
                    ?>
                </select>
            </div>
            <div class="form-group">
                <label for="new_teacher_id">New Teacher:</label>
                <select class="form-control" id="new_teacher_id" name="new_teacher_id" required>
                    <?php
                    while ($teacherRow = $teachersResult->fetch_assoc()) {
                        $selected = ($teacherRow['name'] == $teacher_id) ? 'selected' : '';
                        echo "<option value='{$teacherRow['name']}' $selected>{$teacherRow['name']}</option>";
                    }
                    ?>
                </select>
            </div>
            <div class="form-group">
                <label for="new_day">New Day:</label>
                <select class="form-control" id="new_day" name="new_day" required>
                    <?php
                    foreach ($days as $dayOption) {
                        $selected = ($dayOption == $day) ? 'selected' : '';
                        echo "<option $selected>$dayOption</option>";
                    }
                    ?>
                </select>
            </div>
            <div class="form-group">
                <label for="new_time_start">New Time Start:</label>
                <input type="time" class="form-control" id="new_time_start" name="new_time_start" value="<?php echo $time_start; ?>" required>
            </div>
            <div class="form-group">
                <label for="new_time_end">New Time End:</label>
                <input type="time" class="form-control" id="new_time_end" name="new_time_end" value="<?php echo $time_end; ?>" required>
            </div>
            <button type="submit" class="btn btn-primary">Update Timetable Entry</button>
        </form>
    </div>
    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
</body>
</html>

</div>

<script src="https://code.jquery.com/jquery-3.2.1.slim.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
<script>
    // Function to load content dynamically
    function loadContent(pageId) {
        $.ajax({
            url: pageId,
            type: 'GET',
            success: function (data) {
                $("#main-content").html(data);
            },
            error: function () {
                alert('Error loading content');
            }
        });
    }

    // Set default content to View Timetable
    loadContent("view-timetable.php");

    // Attach click event listeners to sidebar links
    $(".side-bar a").click(function (event) {
        event.preventDefault();
        var pageId = $(this).attr("href");
        loadContent(pageId);
    });
</script>
</body>
</html>
