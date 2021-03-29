--------------------------------
------------------------
--SQL Data Analysis
--Data Analysis Program
------------------------
--------------------------------

USE Hospital
GO

--1. Obtain the names of all physicians that have performed a medical procedure they have never been certified to perform

SELECT Name 
FROM Physician
WHERE EmployeeID IN
   (
      SELECT Un.Physician
      FROM Undergoes un LEFT JOIN Trained_In ti
      ON Un.Physician = ti.Physician
      AND
	  Un.or_procedure = ti.Treatment
      WHERE Treatment IS NULL
   )

-- 2. Obtain the names of all physicians that have performed a medical procedure that they are 
--   certified to perform, but such that the procedure was done at a date (Undergoes.Date) 
--   after the physician's certification expired (Trained_In.CertificationExpires).

SELECT Name
FROM Undergoes un LEFT JOIN Trained_In ti 
ON ti.Physician = un.Physician
AND
ti.Treatment = un.or_procedure 
	LEFT JOIN Physician ph
ON ph.EmployeeID = un.Physician
WHERE ti.CertificationExpires < un.DateUndergoes

-- 3. Obtain the information for appointments where a patient met with a 
--    physician other than his/her primary care physician. 
--    Show the following information: Patient name, physician name, nurse name (if any), 
--    start and end time of appointment, examination room, 
--    and the name of the patient's primary care physician.

SELECT pt.Name AS 'Patiant_name',
	   ph.Name AS 'Physician_name',
	   ns.Name AS 'Nurse_name',
	   ap.Start_time AS 'Start_time',
	   ap.End_time AS 'End_time',
	   ap.ExaminationRoom AS 'Examination_Room',
	   pp.Name AS 'primary_physician'
FROM Appointment ap JOIN Patient pt
ON ap.Patient = pt.SSN
	JOIN
	Physician ph
ON ap.Physician = ph.EmployeeID
	LEFT OUTER JOIN
	Nurse ns
ON ap.PrepNurse = ns.EmployeeID
	JOIN
	Physician pp
ON pp.EmployeeID = pt.PCP
WHERE ap.Physician != pt.PCP

-- 4. The Patient field in Undergoes is redundant, since we can obtain it from the Stay table. 
--    There are no constraints in force to prevent inconsistencies between these two tables. 
--    More specifically - the Undergoes table may include a row where the patient ID does not match the one we would obtain from 
--    the Stay table.
--    Select all rows from Undergoes that exhibit this inconsistency.

SELECT un.Stay AS 'Stay',
	   un.Patient AS 'Undergoes_PatiantID',
	   st.Patient AS 'Stay_PatiantID'
FROM Undergoes un LEFT JOIN Stay st
ON
un.Stay = st.StayID
WHERE un.Patient != st.Patient

-- 5. Obtain the names of all the nurses who have ever been on call for room 123.

SELECT nu.Name
FROM On_Call oc JOIN Room rm
ON oc.BlockFloor = rm.BlockFloor
AND oc.BlockCode = rm.BlockCode
JOIN
Nurse nu
ON oc.Nurse = nu.EmployeeID
WHERE rm.roomNumber = 123

-- 6. The hospital has several examination rooms where appointments take place. 
--    Obtain the number of appointments that have taken place in each examination room.

SELECT ExaminationRoom, COUNT(AppointmentID) AS 'Num_of_appointments' 
FROM Appointment
GROUP BY ExaminationRoom;

-- 7. Obtain the names of all patients who have been prescribed some medication by their primary care 
--    physician

SELECT pt.Name
FROM Patient pt JOIN Prescribes pr
ON pt.SSN = pr.Patient
WHERE pt.PCP = pr.Physician

-- 8. Obtain the names of all patients who have been undergone a procedure with a cost larger that $5,000

SELECT pt.Name
FROM Patient pt JOIN Undergoes un
ON pt.SSN = un.Patient
JOIN or_procedure orp
ON un.or_procedure = orp.Code
WHERE orp.Cost > 5000

-- 9. Obtain the names of all patients who have had at least two appointments 

SELECT COUNT (ap.AppointmentID) AS 'Num_of_App', pt.Name
FROM Patient pt JOIN Appointment ap
ON
pt.SSN = ap.Patient
GROUP BY PT.Name
HAVING COUNT(*) >= 2

-- 10. Obtain the names of all patients which their care physician is not the head of any department 

SELECT pt.Name AS 'Patiant_Name',
	   ph.Name AS 'Primary_care_ph'
FROM Patient pt JOIN Physician ph
ON pt.PCP = ph.EmployeeID
WHERE pt.PCP NOT IN
	(SELECT head FROM Department)

