
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

    

<?php
include 'db_connection.php';

$daysResult = $conn->query("SELECT DISTINCT day FROM timetable");

$selectedDay = isset($_POST['day']) ? sanitizeInput($_POST['day']) : '';
$selectedStartTime = isset($_POST['start_time']) ? sanitizeInput($_POST['start_time']) : '';
$selectedEndTime = isset($_POST['end_time']) ? sanitizeInput($_POST['end_time']) : '';

$availableVenues = [];

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if (!empty($selectedDay) && !empty($selectedStartTime) && !empty($selectedEndTime)) {
        $filledVenues = getFilledVenues($selectedDay, $selectedStartTime, $selectedEndTime);
        $availableVenues = getAvailableVenues($filledVenues);
    }
}

function sanitizeInput($input)
{
    global $conn;
    return mysqli_real_escape_string($conn, htmlspecialchars(strip_tags(trim($input))));
}

function getFilledVenues($day, $startTime, $endTime)
{
    global $conn;

    $filledVenues = [];

    $query = "SELECT DISTINCT venue
              FROM timetable
              WHERE day = '$day'
                AND (
                    (time_start < '$endTime' AND time_end > '$startTime') OR
                    (time_start >= '$startTime' AND time_start < '$endTime') OR
                    (time_end > '$startTime' AND time_end <= '$endTime')
                )";

    $result = $conn->query($query);

    while ($row = $result->fetch_assoc()) {
        $filledVenues[] = $row['venue'];
    }

    return $filledVenues;
}

function getAvailableVenues($filledVenues)
{
    global $conn;

    $query = "SELECT DISTINCT name
              FROM venues
              WHERE name NOT IN ('" . implode("','", $filledVenues) . "')";

    $result = $conn->query($query);

    $availableVenues = [];
    while ($row = $result->fetch_assoc()) {
        $availableVenues[] = $row['name'];
    }

    return $availableVenues;
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Free Venue</title>
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h2>Search Free Venue</h2>

        <form action="" method="post">
            <div class="form-group">
                <label for="day">Day:</label>
                <select class="form-control" id="day" name="day" required>
                    <option value="" disabled>Select Day</option>
                    <?php
                    while ($dayRow = $daysResult->fetch_assoc()) {
                        $selected = ($selectedDay == $dayRow['day']) ? 'selected' : '';
                        echo "<option $selected>{$dayRow['day']}</option>";
                    }
                    ?>
                </select>
            </div>
            <div class="form-row">
                <div class="form-group col-md-6">
                    <label for="start_time">Start Time:</label>
                    <input type="time" class="form-control" id="start_time" name="start_time" required>
                </div>
                <div class="form-group col-md-6">
                    <label for="end_time">End Time:</label>
                    <input type="time" class="form-control" id="end_time" name="end_time" required>
                </div>
            </div>
            <button type="submit" class="btn btn-primary">Search</button>
        </form>

        <?php if (!empty($availableVenues)) : ?>
            <div class="mt-3">
                <h4>Available Venues:</h4>
                <ul>
                    <?php foreach ($availableVenues as $venue) : ?>
                        <li><?php echo $venue; ?></li>
                    <?php endforeach; ?>
                </ul>
            </div>
        <?php endif; ?>
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








