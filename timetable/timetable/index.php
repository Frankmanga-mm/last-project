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
<div class="content" id="main-content">

    <!-- Default content (View Timetable) will be loaded here -->

    <?php
include 'db_connection.php';

$course_query = $conn->query("SELECT DISTINCT name FROM courses");
$level_query = $conn->query("SELECT DISTINCT level FROM courses");

$search_query = isset($_GET['search']) ? $_GET['search'] : '';
$search_condition = '';
if (!empty($search_query)) {
    $search_condition = "AND (course LIKE '%$search_query%' OR level LIKE '%$search_query%' OR subject LIKE '%$search_query%' OR venue LIKE '%$search_query%' OR teacher LIKE '%$search_query%' OR day LIKE '%$search_query%' OR time_start LIKE '%$search_query%' OR time_end LIKE '%$search_query%')";
}

$coursesResult = $conn->query("SELECT DISTINCT name FROM courses");
$venuesResult = $conn->query("SELECT DISTINCT venue FROM timetable");
$levelsResult = $conn->query("SELECT DISTINCT level FROM timetable");

$course = isset($_GET['course']) ? $_GET['course'] : '';
$level = isset($_GET['level']) ? $_GET['level'] : '';

$query = "SELECT *
          FROM timetable
          WHERE course LIKE '%$course%' AND level LIKE '%$level%' $search_condition
          ORDER BY FIELD(day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'), time_start, time_end";
$result = $conn->query($query);

if ($result === false) {
    die("Error executing query: " . $conn->error);
}

$displayTimetable = !empty($course) || !empty($level) || !empty($search_query);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Timetable</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">
    <style>
        .timetable {
            margin-top: 20px;
        }

        .timetable .card {
            margin-bottom: 20px;
        }

        .timetable .card-title {
            font-size: 18px;
            font-weight: bold;
        }

        .timetable .card-text {
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container mt-5">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2>Timetable</h2>
            <a href="add-timetable.php" class="btn btn-primary">Add Timetable</a>
        </div>

        <!-- Filters -->
        <form action="" method="get" class="mb-3">
            <div class="form-row">
                <div class="form-group col-md-4">
                    <label for="course">Course:</label>
                    <select class="form-control" id="course" name="course">
                        <option value="" selected>All Courses</option>
                        <?php
                        while ($courseRow = $coursesResult->fetch_assoc()) {
                            $selected = ($course == $courseRow['name']) ? 'selected' : '';
                            echo "<option $selected>{$courseRow['name']}</option>";
                        }
                        ?>
                    </select>
                </div>
                <div class="form-group col-md-4">
                    <label for="level">Level:</label>
                    <select class="form-control" id="level" name="level">
                        <option value="" selected>All Levels</option>
                        <?php
                        while ($levelRow = $levelsResult->fetch_assoc()) {
                            $selected = ($level == $levelRow['level']) ? 'selected' : '';
                            echo "<option $selected>{$levelRow['level']}</option>";
                        }
                        ?>
                    </select>
                </div>
                <div class="form-group col-md-4">
                    <label for="search">Search:</label>
                    <input type="text" class="form-control" id="search" name="search" value="<?php echo $search_query; ?>">
                </div>
            </div>
            <button type="submit" class="btn btn-primary">Apply Filters</button>
        </form>

        <!-- Timetable Cards -->
        <?php
        if ($displayTimetable) {
            $currentDay = null;
            echo "<div class='row timetable'>";
            while ($entry = $result->fetch_assoc()) {
                if ($entry['day'] != $currentDay) {
                    if ($currentDay !== null) {
                        echo "</div></div>";
                    }
                    echo "<div class='col-md-12'><h4>{$entry['day']}</h4><div class='card-deck'>";
                    $currentDay = $entry['day'];
                }

                echo "<div class='card'>
                        <div class='card-body'>
                            <h5 class='card-title'>{$entry['time_start']} - {$entry['time_end']}</h5>";
                
                echo "<p class='card-text'>
                        <strong>Subject:</strong> {$entry['subject']}<br>
                        <strong>Teacher:</strong> {$entry['teacher']}<br>
                        <strong>Venue:</strong> {$entry['venue']}<br>
                        <strong>course:</strong> {$entry['course']}<br>
                        <strong>level:</strong> {$entry['level']}<br>
                        </p>";

                echo "</div></div>";

            }
            echo "</div></div>";
        } else {
            echo "<p>Explore the timetable by applying filters or searching.</p>";
        }
        ?>
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
