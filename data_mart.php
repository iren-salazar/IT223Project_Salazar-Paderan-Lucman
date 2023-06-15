
<?php

// Establish a database connection
$servername = "localhost";
$username = "root";
$password = "password";
$dbname = "railwayreservation";

// Create a connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check the connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Perform a database query to retrieve the data
$sql = "SELECT p.trainNumber, p.destination, p.dateBooked, COUNT(*) AS passengerCount, ta.category, ta.date FROM passenger p JOIN trainlist tl ON p.trainNumber = tl.trainNumber JOIN train_status ts ON p.trainNumber = ts.trainNumber AND p.dateBooked = ts.trainDate LEFT JOIN trainaudit ta ON p.trainNumber = ta.trainNumber GROUP BY p.trainNumber, p.destination, p.dateBooked, ta.category, ta.date;";
$result = $conn->query($sql);

$data_collection = [];
if ($result->num_rows > 0) {
    // Loop through the query result and populate the data collection array
    while ($row = $result->fetch_assoc()) {
        $id = $row['trainNumber'] . '-' . $row['destination'] . '-' . $row['date'];
        if (!isset($data_collection[$id])) {
            $data_collection[$id] = 0;
        }
        $data_collection[$id] += $row['passengerCount'];
    }
}

// Close the database connection
$conn->close();

// Create the XML file
$xml = new SimpleXMLElement('<Trains></Trains>');
foreach ($data_collection as $id => $passengersHere) {
    $data_split = explode('-', $id);
    $trainHere = $xml->addChild('Train');
    $trainHere->addChild('trainNumber', $data_split[0]);
    $trainHere->addChild('destination', $data_split[1]);
    $trainHere->addChild('date', $data_split[2]);
    $trainHere->addChild('passengerCount', $passengersHere);
}

// Save the XML file
$xml->asXML('myTrain_data.xml');
?>

<!DOCTYPE html>
<html>
<head>
    <title>Train Data</title>
    <style>
        
        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #f2f2f2;
        }

        tr:hover {
            background-color: #f5f5f5;
        }
    </style>
    </style>
    //you can create separate file for the css of your webpage and link the file here in the head section
</head>
<body>
    <table>
        <thead>
            <tr>
                <th>Train ID</th>
                <th>Destination</th>
                <th>Date</th>
                <th>Number of Passengers</th>
            </tr>
        </thead>
        <tbody>
            <?php
            $xml = simplexml_load_file('myTrain_data.xml');
            foreach ($xml->Train as $train) {
                echo '<tr>';
                echo '<td>' . $train->trainNumber. '</td>';
                echo '<td>' . $train->destination . '</td>';
                echo '<td>' . $train->date. '</td>';
                echo '<td>' . $train->passengerCount. '</td>';
                echo '</tr>';
            }
            ?>
        </tbody>
    </table>
</body>
</html>