<?php
include 'db_connection.php';
require('TCPDF/tcpdf.php');

// Get selected course and level from the URL parameters
$course = isset($_GET['course']) ? $_GET['course'] : '';
$level = isset($_GET['level']) ? $_GET['level'] : '';

// Generate PDF
$pdf = new TCPDF();
$pdf->AddPage();
$pdf->SetFont('times', 'B', 16);
$pdf->Cell(0, 10, "Timetable - $course - $level", 0, 1, 'C');

// Fetch and display timetable entries
$query = "SELECT *
          FROM timetable
          WHERE course LIKE '%$course%' AND level LIKE '%$level%'
          ORDER BY FIELD(day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'), time_start, time_end";
$result = $conn->query($query);

if ($result === false) {
    die("Error executing query: " . $conn->error);
}

// Table header
$pdf->SetFont('times', 'B', 12);
$pdf->Ln(10);
$pdf->Cell(25, 10, 'Day', 1, 0, 'C');
$pdf->Cell(35, 10, 'Time', 1, 0, 'C');
$pdf->Cell(60, 10, 'Subject', 1, 0, 'C');
$pdf->Cell(33, 10, 'Lecturer', 1, 0, 'C');
$pdf->Cell(30, 10, 'Venue', 1, 0, 'C');
$pdf->Ln();

// Table content
$pdf->SetFont('times', '', 12);
$currentDay = null;

while ($entry = $result->fetch_assoc()) {
    if ($entry['day'] != $currentDay) {
        if ($currentDay !== null) {
            $pdf->Ln();
        }
        $pdf->Cell(25, 10, $entry['day'], 1);
        $currentDay = $entry['day'];
    } else {
        $pdf->Cell(25, 10, '', 1);
    }

    $pdf->Cell(35, 10, "{$entry['time_start']} - {$entry['time_end']}", 1);
    $pdf->Cell(60, 10, $entry['subject'], 1);
    $pdf->Cell(33, 10, $entry['teacher'], 1);
    $pdf->Cell(30, 10, $entry['venue'], 1);
    $pdf->Ln();
}

// Output PDF
$pdf->Output();
?>
