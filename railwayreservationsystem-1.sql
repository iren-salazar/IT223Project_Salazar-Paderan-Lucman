-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 07, 2023 at 03:08 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `railwayreservationsystem`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `bookingReportAC` (IN `trainNo` VARCHAR(10), IN `d` DATE)   BEGIN
DECLARE c int;
DECLARE conf int;
DECLARE pend int;

SELECT COUNT(*) into c FROM (SELECT trainNumber, dateBooked, count(trainNumber) FROM passenger WHERE trainNumber = trainNo AND dateBooked = d AND category = 1 GROUP BY status) as t;
IF c = 0 THEN
    SET conf = 0;
    SET pend = 0;
    SELECT trainNo, d as date, conf as Confirmed, pend as Waiting;
END IF;
IF c <> 0 THEN
  SELECT count(trainNumber) INTO conf FROM passenger WHERE trainNumber = trainNo AND dateBooked = d AND category = 1 AND status = 'Confirmed' GROUP BY status;
  SELECT count(trainNumber) INTO pend FROM passenger WHERE trainNumber = trainNo AND dateBooked = d AND category = 1 AND status = 'Pending'  GROUP BY status;
  SELECT trainNo, d as date, conf as Confirmed, pend as Waiting;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `bookingReportGen` (IN `trainNo` VARCHAR(10), IN `d` DATE)   BEGIN 
DECLARE c int;
DECLARE conf int;
DECLARE pend int;

SELECT COUNT(*) into c FROM (SELECT trainNumber, dateBooked, count(trainNumber) FROM passenger WHERE trainNumber = trainNo AND dateBooked = d AND category = 2 GROUP BY status) as t;
IF c = 0 THEN
    SET conf = 0;
    SET pend = 0;
    SELECT trainNo, d as date, conf as Confirmed, pend as Waiting;
END IF;
IF c <> 0 THEN
  SELECT count(trainNumber) INTO conf FROM passenger WHERE trainNumber = trainNo AND dateBooked = d AND category = 2 AND status = 'Confirmed' GROUP BY status;
  SELECT count(trainNumber) INTO pend FROM passenger WHERE trainNumber = trainNo AND dateBooked = d AND category = 2 AND status = 'Pending'  GROUP BY status;
  SELECT trainNo, d as date, conf as Confirmed, pend as Waiting;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `bookTicket` (IN `TN` VARCHAR(10), IN `DB` DATE, IN `r` INT, IN `Sr` VARCHAR(50), IN `Ds` VARCHAR(50), IN `sched` VARCHAR(10), IN `tm` TIME, IN `cat` INT, IN `n` VARCHAR(50), IN `a` INT, IN `s` VARCHAR(1), IN `addr` VARCHAR(50))   BEGIN
DECLARE c int;
DECLARE addSeat int;
DECLARE stat varchar(50);
SELECT COUNT(*) INTO c FROM train_status WHERE trainNumber=TN AND trainDate = DB AND route = r;
IF c = 0 THEN
	IF cat = 1 THEN
		INSERT INTO train_status(trainNumber, trainDate, route, totalACSeats, totalGenSeats, ACSeatsBooked, GenSeatsBooked)
		VALUES(TN, DB, r, 10,10, 1, 0);
	ELSEIF cat = 2 THEN
		INSERT INTO train_status(trainNumber, trainDate, route, totalACSeats, totalGenSeats, ACSeatsBooked, GenSeatsBooked)
		VALUES(TN, DB, r, 10,10, 0, 1);   
    END IF;
END IF;

INSERT INTO passenger(trainNumber, dateBooked, route, source, destination, schedule, tm, category, status, name, age, sex, address)
VALUES(TN, DB, r, Sr, Ds, sched, tm, cat, 'Confirmed', n, a, s, addr);

IF c <> 0 THEN
	IF cat = 1 THEN
    SELECT ACSeatsBooked INTO addSeat FROM train_status WHERE trainNumber=TN AND trainDate = DB AND route = r;
    SET addSeat = addSeat + 1;
	UPDATE train_status SET ACSeatsBooked = addSeat WHERE trainNumber=TN AND trainDate = DB AND route = r;
    ELSEIF cat = 2 THEN
    SELECT GenSeatsBooked INTO addSeat FROM train_status WHERE trainNumber=TN AND trainDate = DB AND route = r;
    SET addSeat = addSeat + 1;
	UPDATE train_status SET GenSeatsBooked = addSeat WHERE trainNumber=TN AND trainDate = DB AND route = r;
	END IF;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cancelTicket` (IN `tID` INT)   BEGIN
DECLARE updateID int;
DECLARE tNo varchar(10);
DECLARE dBooked DATE;
DECLARE rt int;
DECLARE cat int;
DECLARE bookedSeat int;


SELECT trainNumber into tNo FROM passenger WHERE ticketID = tID;
SELECT dateBooked into dBooked FROM passenger WHERE ticketID = tID;
SELECT route into rt FROM passenger WHERE ticketID = tID;
SELECT category into cat FROM passenger WHERE ticketID = tID;

SELECT ticketID into updateID FROM passenger WHERE trainNumber = tNo AND dateBooked = dBooked AND route = rt AND status = 'Pending' LIMIT 1;

DELETE FROM passenger WHERE ticketID = tID;

UPDATE passenger SET status = 'Confirmed' WHERE ticketID = updateID;

IF cat = 1 THEN
	SELECT ACSeatsBooked into bookedSeat FROM train_status WHERE trainNumber = tNo AND trainDate = dBooked AND route = rt;
    SET bookedSeat = bookedSeat - 1;
    UPDATE train_status SET ACSeatsBooked = bookedSeat WHERE trainNumber = tNo AND trainDate = dBooked AND route = rt;


ELSE
	SELECT GenSeatsBooked into bookedSeat FROM train_status WHERE trainNumber = tNo AND trainDate = dBooked AND route = rt;
	SET bookedSeat = bookedSeat - 1;
	UPDATE train_status SET GenSeatsBooked = bookedSeat WHERE trainNumber = tNo AND trainDate = dBooked AND route = rt;
    

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `chk_trainAvailability` (IN `d` DATE, IN `r` INT, IN `cat` INT)   BEGIN

DECLARE c int;
IF cat = 1 THEN
	SELECT COUNT(*) INTO c FROM train_status WHERE trainDate = d AND route = r;
END IF;
IF cat = 2 THEN 
	SELECT COUNT(*) INTO c FROM train_status WHERE trainDate = d AND route = r;
END IF;

IF c = 0 THEN
	IF r = 1 AND DAY(d)%2 <> 0 THEN
		SELECT trainNumber FROM trainlist LIMIT 5;
	END IF;
	IF r = 1 AND DAY(d)%2 = 0 THEN 
		SELECT trainNumber FROM trainlist ORDER BY trainNumber DESC LIMIT 5;
	END IF;
	IF r = 2 AND DAY(d)%2 <> 0 THEN
		SELECT trainNumber FROM trainlist ORDER BY trainNumber DESC LIMIT 5;
	END IF;
	IF r = 2 AND DAY(d)%2 = 0 THEN
		SELECT trainNumber FROM trainlist LIMIT 5;
	END IF;
END IF;

IF c <> 0 THEN
	IF cat = 1 THEN 
		SELECT * FROM train_status WHERE trainDate = d AND route = r AND totalACSeats <> ACSeatsBooked + 2;
	END IF;
	IF cat = 2 THEN
		SELECT * FROM train_status WHERE trainDate = d AND route = r AND totalGenSeats <> GenSeatsBooked + 2;
	END IF;
END IF;

END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `getDate` (`tID` INT) RETURNS DATE  BEGIN
DECLARE d DATE;
SELECT dateBooked INTO d FROM passenger WHERE ticketID = tID;
RETURN d;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `passenger`
--

CREATE TABLE `passenger` (
  `ticketID` bigint(20) UNSIGNED NOT NULL,
  `trainNumber` varchar(10) NOT NULL,
  `dateBooked` date NOT NULL,
  `name` varchar(100) NOT NULL,
  `age` int(3) NOT NULL,
  `sex` varchar(1) NOT NULL,
  `address` varchar(100) NOT NULL,
  `status` varchar(50) DEFAULT NULL,
  `category` varchar(50) NOT NULL,
  `source` varchar(50) DEFAULT NULL,
  `destination` varchar(50) DEFAULT NULL,
  `schedule` varchar(10) DEFAULT NULL,
  `tm` time DEFAULT NULL,
  `route` int(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `passenger`
--

INSERT INTO `passenger` (`ticketID`, `trainNumber`, `dateBooked`, `name`, `age`, `sex`, `address`, `status`, `category`, `source`, `destination`, `schedule`, `tm`, `route`) VALUES
(17, 'T01', '2023-06-03', 'Niel', 20, 'M', 'Bugo', 'Confirmed', '1', 'CDO', 'DAVAO', 'PM1', '12:00:00', 1),
(18, 'T01', '2023-06-03', 'Niel', 20, 'M', 'Bugo', 'Confirmed', '1', 'CDO', 'DAVAO', 'PM1', '12:00:00', 1),
(19, 'T01', '2023-06-03', 'Niel', 20, 'M', 'Bugo', 'Confirmed', '1', 'CDO', 'DAVAO', 'PM1', '12:00:00', 1),
(26, 'T01', '2023-06-03', 'Niel', 20, 'M', 'Bugo', 'Confirmed', '1', 'CDO', 'DAVAO', 'PM1', '12:00:00', 1),
(29, 'T01', '2023-06-03', 'Niel', 20, 'm', 'Bugo', 'Confirmed', '1', 'CDO', 'DAVAO', 'PM1', '12:00:00', 1),
(30, 'T01', '2023-06-03', 'Niel', 20, 'm', 'Bugo', 'Confirmed', '1', 'CDO', 'DAVAO', 'PM1', '12:00:00', 1),
(31, 'T01', '2023-06-03', 'Niel', 20, 'm', 'Bugo', 'Confirmed', '1', 'CDO', 'DAVAO', 'PM1', '12:00:00', 1),
(32, 'T01', '2023-06-03', 'Niel', 20, 'm', 'Bugo', 'Confirmed', '1', 'CDO', 'DAVAO', 'PM1', '12:00:00', 1),
(33, 'T01', '2023-06-03', 'Niel', 20, 'm', 'Bugo', 'Confirmed', '1', 'CDO', 'DAVAO', 'PM1', '12:00:00', 1),
(34, 'T01', '2023-06-03', 'Niel', 20, 'm', 'Bugo', 'Confirmed', '1', 'CDO', 'DAVAO', 'PM1', '12:00:00', 1),
(35, 'T01', '2023-06-03', 'Niel', 20, 'm', 'Bugo', 'Pending', '1', 'CDO', 'DAVAO', 'PM1', '12:00:00', 1);

--
-- Triggers `passenger`
--
DELIMITER $$
CREATE TRIGGER `addAudit` AFTER UPDATE ON `passenger` FOR EACH ROW BEGIN

INSERT INTO trainaudit(trainNumber, date, category) VALUES (OLD.trainNumber, TIMESTAMP(NOW()), OLD.category);

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `chk_tLimit` BEFORE INSERT ON `passenger` FOR EACH ROW BEGIN
DECLARE bookedSeats int;
DECLARE totalSeats int;
DECLARE pending int;

IF NEW.category = 1 THEN
	SELECT ACSeatsBooked INTO bookedSeats FROM train_status WHERE trainNumber = NEW.trainNumber AND trainDate = NEW.dateBooked AND route = NEW.route;
	IF bookedSeats >= 10 THEN
    	SELECT COUNT(status) INTO pending FROM passenger WHERE trainNumber = NEW.trainNumber AND dateBooked = NEW.dateBooked AND route = NEW.route AND category = NEW.category AND status='Pending';
        IF pending = 2 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'train is at max capacity!';
		END IF;
        SET NEW.status = 'Pending';
	END IF;
END IF;

IF NEW.category = 2 THEN
	SELECT GenSeatsBooked INTO bookedSeats FROM train_status WHERE trainNumber = NEW.trainNumber AND trainDate = NEW.dateBooked AND route = NEW.route;
	IF bookedSeats = 10 THEN
    	SELECT COUNT(status) INTO pending FROM passenger WHERE trainNumber = NEW.trainNumber AND dateBooked = NEW.dateBooked AND route = NEW.route AND category = NEW.category AND status='Pending';
    	IF pending = 2 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'train is at max capacity!';
		END IF;
        SET NEW.status = 'Pending';
	END IF;
END IF;


END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `trainaudit`
--

CREATE TABLE `trainaudit` (
  `trainNumber` varchar(10) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  `date` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `trainaudit`
--

INSERT INTO `trainaudit` (`trainNumber`, `category`, `date`) VALUES
('T01', '1', '2023-06-05 07:24:05');

-- --------------------------------------------------------

--
-- Table structure for table `trainlist`
--

CREATE TABLE `trainlist` (
  `trainNumber` varchar(10) NOT NULL,
  `trainName` varchar(100) NOT NULL,
  `source` varchar(100) NOT NULL,
  `destination` varchar(100) NOT NULL,
  `AC_fare` float(10,2) NOT NULL,
  `GEN_fare` float(10,2) NOT NULL,
  `mon` tinyint(1) NOT NULL,
  `tue` tinyint(1) NOT NULL,
  `wed` tinyint(1) NOT NULL,
  `thur` tinyint(1) NOT NULL,
  `fri` tinyint(1) NOT NULL,
  `sat` tinyint(1) NOT NULL,
  `sun` tinyint(1) NOT NULL,
  `schedule` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `trainlist`
--

INSERT INTO `trainlist` (`trainNumber`, `trainName`, `source`, `destination`, `AC_fare`, `GEN_fare`, `mon`, `tue`, `wed`, `thur`, `fri`, `sat`, `sun`, `schedule`) VALUES
('T01', 'OrangeTrain', 'CDO-DAVAO', 'CDO-DAVAO', 200.00, 150.00, 1, 1, 1, 1, 1, 1, 1, 'AM'),
('T02', 'BlueTrain', 'CDO-DAVAO', 'CDO-DAVAO', 200.00, 150.00, 1, 1, 1, 1, 1, 1, 1, 'PM'),
('T03', 'TGV', 'CDO-DAVAO', 'CDO-DAVAO', 200.00, 150.00, 1, 1, 1, 1, 1, 1, 1, 'PM'),
('T04', 'GoldenTime', 'CDO-DAVAO', 'CDO-DAVAO', 200.00, 150.00, 1, 1, 1, 1, 1, 1, 1, 'EVE'),
('T05', 'ComfyCruiser', 'CDO-DAVAO', 'CDO-DAVAO', 200.00, 150.00, 1, 1, 1, 1, 1, 1, 1, 'EVE'),
('T06', 'LightWave', 'CDO-DAVAO', 'CDO-DAVAO', 200.00, 150.00, 1, 1, 1, 1, 1, 1, 1, 'AM'),
('T07', 'HeatRan', 'CDO-DAVAO', 'CDO-DAVAO', 200.00, 150.00, 1, 1, 1, 1, 1, 1, 1, 'PM'),
('T08', 'AyeTrain', 'CDO-DAVAO', 'CDO-DAVAO', 200.00, 150.00, 1, 1, 1, 1, 1, 1, 1, 'PM'),
('T09', 'Hyperion', 'CDO-DAVAO', 'CDO-DAVAO', 200.00, 150.00, 1, 1, 1, 1, 1, 1, 1, 'EVE'),
('T10', 'Katipunan', 'CDO-DAVAO', 'CDO-DAVAO', 200.00, 150.00, 1, 1, 1, 1, 1, 1, 1, 'EVE');

-- --------------------------------------------------------

--
-- Table structure for table `train_status`
--

CREATE TABLE `train_status` (
  `trainNumber` varchar(10) NOT NULL,
  `trainDate` date NOT NULL,
  `totalACSeats` int(11) NOT NULL,
  `totalGenSeats` int(11) NOT NULL,
  `ACSeatsBooked` int(11) NOT NULL,
  `GenSeatsBooked` int(11) NOT NULL,
  `route` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `train_status`
--

INSERT INTO `train_status` (`trainNumber`, `trainDate`, `totalACSeats`, `totalGenSeats`, `ACSeatsBooked`, `GenSeatsBooked`, `route`) VALUES
('T01', '2023-06-03', 10, 10, 11, 0, '1'),
('T02', '2023-06-03', 10, 10, 0, 0, '1');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `passenger`
--
ALTER TABLE `passenger`
  ADD PRIMARY KEY (`ticketID`),
  ADD UNIQUE KEY `ticketID` (`ticketID`),
  ADD KEY `fk_trainNumber` (`trainNumber`);

--
-- Indexes for table `trainaudit`
--
ALTER TABLE `trainaudit`
  ADD KEY `fk_trainNum` (`trainNumber`);

--
-- Indexes for table `trainlist`
--
ALTER TABLE `trainlist`
  ADD PRIMARY KEY (`trainNumber`);

--
-- Indexes for table `train_status`
--
ALTER TABLE `train_status`
  ADD KEY `fk_trainNo` (`trainNumber`) USING BTREE;

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `passenger`
--
ALTER TABLE `passenger`
  MODIFY `ticketID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `passenger`
--
ALTER TABLE `passenger`
  ADD CONSTRAINT `fk_trainNumber` FOREIGN KEY (`trainNumber`) REFERENCES `trainlist` (`trainNumber`);

--
-- Constraints for table `trainaudit`
--
ALTER TABLE `trainaudit`
  ADD CONSTRAINT `fk_trainNum` FOREIGN KEY (`trainNumber`) REFERENCES `trainlist` (`trainNumber`);

--
-- Constraints for table `train_status`
--
ALTER TABLE `train_status`
  ADD CONSTRAINT `fk_trainNo` FOREIGN KEY (`trainNumber`) REFERENCES `trainlist` (`trainNumber`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
