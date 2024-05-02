
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

// Initialize variables for error message and data
$errorMsg = '';
$venue_name = '';
$venue_capacity = '';

// Check if the form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Sanitize and validate form data
    $venue_id = sanitizeInput($_POST["venue_id"]);
    $new_name = sanitizeInput($_POST["new_name"]);
    $new_capacity = sanitizeInput($_POST["new_capacity"]);

    if (empty($new_name) || empty($new_capacity)) {
        $errorMsg = '<span style="color: red;">Please fill in all fields.</span>';
    } else {
        // Update the venue's name and capacity
        $conn->query("UPDATE venues SET name = '$new_name', capacity = '$new_capacity' WHERE id = $venue_id");
        header("Location: view-venues.php"); // Redirect to the venues page after updating
        exit();
    }
}

// Check if the venue ID is provided in the URL
if (isset($_GET["id"])) {
    $venue_id = $_GET["id"];

    // Retrieve the venue's information
    $result = $conn->query("SELECT * FROM venues WHERE id = $venue_id");

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $venue_name = $row["name"];
        $venue_capacity = $row["capacity"];
    } else {
        echo "Venue not found.";
        exit();
    }
} else {
    echo "Venue ID not provided.";
    exit();
}

// Function to sanitize input
function sanitizeInput($input)
{
    global $conn;
    return mysqli_real_escape_string($conn, htmlspecialchars(strip_tags(trim($input))));
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Venue</title>
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }

        .container {
            margin-top: 50px;
        }

        h2 {
            color: #007bff;
        }

        .error-msg {
            color: red;
        }
    </style>
</head>
<body>
    <div class="container mt-5">
        <h2>Edit Venue</h2>

        <!-- Display error message -->
        <?php echo $errorMsg; ?>

        <form action="" method="post">
            <input type="hidden" name="venue_id" value="<?php echo $venue_id; ?>">
            <div class="form-group">
                <label for="new_name">New Name:</label>
                <input type="text" class="form-control" id="new_name" name="new_name" value="<?php echo $venue_name; ?>">
            </div>
            <div class="form-group">
                <label for="new_capacity">New Capacity:</label>
                <input type="text" class="form-control" id="new_capacity" name="new_capacity" value="<?php echo $venue_capacity; ?>">
            </div>
            <button type="submit" class="btn btn-primary">Update Venue</button>
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












