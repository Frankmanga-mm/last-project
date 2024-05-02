
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


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Timetable Entry</title>
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <?php
    include 'db_connection.php';

    $coursesResult = $conn->query("SELECT DISTINCT name FROM courses");
    $venuesResult = $conn->query("SELECT DISTINCT name FROM venues");
    $levelsResult = $conn->query("SELECT DISTINCT level FROM courses");

    $course = $level = $subject = $venue = $teacher = $day = $time_start = $time_end = '';
    $errorMsg = '';

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $course = sanitizeInput($_POST["course"]);
        $level = sanitizeInput($_POST["level"]);
        $subject = sanitizeInput($_POST["subject"]);
        $venue = sanitizeInput($_POST["venue"]);
        $teacher = sanitizeInput($_POST["teacher"]);
        $day = sanitizeInput($_POST["day"]);
        $time_start = sanitizeInput($_POST["time_start"]);
        $time_end = sanitizeInput($_POST["time_end"]);

        if (empty($course) || empty($level) || empty($subject) || empty($venue) || empty($teacher) || empty($day) || empty($time_start) || empty($time_end)) {
            $errorMsg = '<div class="alert alert-danger" role="alert">Please fill in all fields.</div>';
        } else {
            if (isSubjectAvailable($course, $level, $day, $time_start, $time_end)) {
                if (isVenueAvailable($course, $level, $subject, $venue, $day, $time_start, $time_end)) {
                    if (isTeacherAvailable($teacher, $day, $time_start, $time_end)) {
                        $insertQuery = "INSERT INTO timetable (course, level, subject, venue, teacher, day, time_start, time_end) VALUES ('$course', '$level', '$subject', '$venue', '$teacher', '$day', '$time_start', '$time_end')";

                        if ($conn->query($insertQuery)) {
                            header("Location: view-timetable.php");
                            exit();
                        } else {
                            $errorMsg = '<div class="alert alert-danger" role="alert">Error: ' . $conn->error . '</div>';
                        }
                    } else {
                        $errorMsg = '<div class="alert alert-danger" role="alert">The specified Lecturer is not available at the specified time, he has been already assigned a module in another course. Please check out the timetable to avoid mistakes.</div>';
                    }
                } else {
                    $errorMsg = '<div class="alert alert-danger" role="alert">Venue is not available at the specified time. Please choose a different venue or time slot.</div>';
                }
            } else {
                $errorMsg = '<div class="alert alert-danger" role="alert"> This level of the specificed course has already been assigned a subject at that particular time interval , please find another time slot</div>';
            }
        }
    }

    function sanitizeInput($input)
    {
        global $conn;
        return mysqli_real_escape_string($conn, htmlspecialchars(strip_tags(trim($input))));
    }

    function isSubjectAvailable($course, $level, $day, $startTime, $endTime)
    {
        global $conn;

        $query = "SELECT * FROM timetable WHERE course = '$course' AND level = '$level' AND day = '$day' AND (
                    (time_start <= '$startTime' AND time_end >= '$startTime') OR
                    (time_start <= '$endTime' AND time_end >= '$endTime') OR
                    ('$startTime' <= time_start AND '$endTime' >= time_start)
                )";

        $result = $conn->query($query);

        return $result->num_rows === 0;
    }

    function isVenueAvailable($course, $level, $subject, $venue, $day, $startTime, $endTime)
    {
        global $conn;

        $query = "SELECT * FROM timetable WHERE venue = '$venue' AND day = '$day' AND (
                    (time_start <= '$startTime' AND time_end >= '$startTime') OR
                    (time_start <= '$endTime' AND time_end >= '$endTime') OR
                    ('$startTime' <= time_start AND '$endTime' >= time_start)
                ) AND (course != '$course' OR level != '$level' OR subject != '$subject')";

        $result = $conn->query($query);

        return $result->num_rows === 0;
    }

    function isTeacherAvailable($teacher, $day, $startTime, $endTime)
    {
        global $conn;

        $query = "SELECT * FROM timetable WHERE teacher = '$teacher' AND day = '$day' AND (
                    (time_start <= '$startTime' AND time_end >= '$startTime') OR
                    (time_start <= '$endTime' AND time_end >= '$endTime') OR
                    ('$startTime' <= time_start AND '$endTime' >= time_start)
                )";

        $result = $conn->query($query);

        if ($result->num_rows > 0) {
            $assignments = [];
            while ($row = $result->fetch_assoc()) {
                $assignments[] = "Course: {$row['course']}, Level: {$row['level']}, Venue: {$row['venue']}, Day: {$row['day']}, Time: {$row['time_start']} - {$row['time_end']}";
            }

            $GLOBALS['errorMsg'] = '<div class="alert alert-danger" role="alert">Teacher is already assigned at the specified time. Current assignments:<br>' . implode('<br>', $assignments) . '</div>';
        }

        return $result->num_rows === 0;
    }
    ?>

    <div class="container mt-5">
        <h2>Add Timetable Entry</h2>

        <?php echo $errorMsg; ?>

        <form action="" method="post">
            <div class="form-group">
                <label for="course">Course:</label>
                <select class="form-control" id="course" name="course" required>
                    <option value="" disabled selected>Select Course</option>
                    <?php
                    while ($courseRow = $coursesResult->fetch_assoc()) {
                        echo "<option value='{$courseRow['name']}'>{$courseRow['name']}</option>";
                    }
                    ?>
                </select>
            </div>
            <div class="form-group">
                <label for="level">Level:</label>
                <select class="form-control" id="level" name="level" required>
                    <option value="" disabled selected>Select Level</option>
                    <?php
                    while ($levelRow = $levelsResult->fetch_assoc()) {
                        echo "<option>{$levelRow['level']}</option>";
                    }
                    ?>
                </select>
            </div>
            <div class="form-group">
                <label for="subject">Subject:</label>
                <input type="text" class="form-control" id="subject" name="subject">
            </div>
            <div class="form-group">
                <label for="venue">Venue:</label>
                <select class="form-control" id="venue" name="venue" required>
                    <option value="" disabled selected>Select Venue</option>
                    <?php
                    while ($venueRow = $venuesResult->fetch_assoc()) {
                        echo "<option>{$venueRow['name']}</option>";
                    }
                    ?>
                </select>
            </div>
            <div class="form-group">
                <label for="teacher">Teacher:</label>
                <input type="text" class="form-control" id="teacher" name="teacher">
            </div>
            <div class="form-group">
                <label for="day">Day:</label>
                <select class="form-control" id="day" name="day" required>
                    <option value="" disabled selected>Select Day</option>
                    <option>Monday</option>
                    <option>Tuesday</option>
                    <option>Wednesday</option>
                    <option>Thursday</option>
                    <option>Friday</option>
                    <option>Saturday</option>
                </select>
            </div>
            <div class="form-group">
                <label for="time_start">Time Start:</label>
                <input type="time" class="form-control" id="time_start" name="time_start">
            </div>
            <div class="form-group">
                <label for="time_end">Time End:</label>
                <input type="time" class="form-control" id="time_end" name="time_end">
            </div>
            <button type="submit" class="btn btn-primary">Add Timetable Entry</button>
        </form>
    </div>
    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
</body>
</html>

<!-- end of add-timetable -->
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


