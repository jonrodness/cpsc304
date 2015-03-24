########User: Pharmacists

# qPh1 view prescriptions prescribed by doctor
#chris-checked
#jon-checked: entered and working
select Pr.PrescriptID
from Prescription Pr, Doctor D
where Pr.LicenseNum=D.LicenseNum;

# qPh2 change status of prescription (not ready for pick up, ready for pick up) (**need to add as attribute)
#chris-checked
#jon-checked: entered, need to add PrescriptID variable
update Prescription
    set ReadyForPickUp=1
    where PrescriptID ='3456' AND ReadyForPickup=0;

# qPh3 can view past prescriptions for patient
#chris-checked
#jon-checked: entered, need to add CareCardNum variable
select Pr.date_prescribed,I.GenericName,Pr.Refills,Pr.Dosage
from Prescription Pr, Patient P, Includes I
where Pr.CareCardNum=P.CareCardNum AND I.PrescriptID=Pr.PrescriptID AND Pr.CareCardNum=1234567890
Order By Pr.date_prescribed;

# qPh4 can print out a list of prescriptions filled that day
#chris-checked
#jon - checked, test with current day record
select I.GenericName, Pr.Dosage
from Prescription Pr, Patient P, Includes I
where Pr.PrescriptID=I.PrescriptID AND Pr.CareCardNum=P.CareCardNum AND Pr.date_prescribed=curdate();

# qPh5 can reduce the refill number of a patient’s prescription
#chris-checked
#jon-checked: entered, need to add PRESCRIPT ID variable
update Prescription
    set Refills=Refills-1
    where PrescriptID='3456' AND Refills > 0;

########User: Patients

# qPa1----update personal information about him/herself
#	?????? so many possible attributes to update?
#	 sample query: patient carecard num = 1234567890
#	 store all attrs of the patient in some variables
#	 in our query, either set the attribute to a new value that the user entered, or the old value that we stored in variables 
#jon-checked: entered, need to add VARIABLES for firstname, lastname, age, weight, height, address, phonenumber, CareCardNum
update Patient
set FirstName = 'blabla',
    LastName = 'blabla',
    Age = 'blabla',
    Weight = 'blabla',
    Height = 'blabla',
    Address = 'blabla',
    PhoneNumber = 'blabla'
where P.CareCardNum LIKE '1234567890'; 


#----can input an address and a radius and see a list of doctors offices within the indicated radius of the indicated address
	# this is gonna be complicated omg
#----select doctor attributes from doctor tables and filter by attributes
	# what does this even mean 

# qPa2------select pharmacies that are currently open
#chris--in one query or 2?
#jon -checked: entered, working, reformat
select *
from Pharmacy P
where curtime() between P.WeekdayHoursOpening and P.WeekdayHoursClosing;


# qPa3------select pharmacies that are currently open
#chris
#jon -checked: entered, working, reformat
select *
from Pharmacy P
where curtime() between P.WeekendHoursOpening and P.WeekendHoursClosing;


#given a date/time, view pharmacies that are open at that date/time
	# implemented above

#can input an address and a radius and as a result, can view a list of pharmacies that are open at the moment , within the indicated radius of the indicated address
	# too hard man, now we gotta use google service to translate addresses into coordinates and calculate distances, eff this
#request permission to add a doctor to their personal list of doctors
	# nope, we dont store personal list of doctors

#can select a personal doctor by name and last name and view a list of time blocks when the doctor is available
	# i dont think this is possible to implement 

# qPa4
#jon -checked: entered, add variables
#can create an appointment with any doctor at any given time, as long
# 	 as the doctor is available during that time and the appointment is within business hours
# 	first, we gotta create a timeblock tuple 
# 	second, recall MakesAppointmentWith(TimeMade, DateMade,LicenseNum,TimeBlockDate, StartTime, EndTime, CareCardNum)
insert into TimeBlock
values (
		'2874-06-07',
		'12:30:00',
		'15:30:00'
);
insert into MakesAppointmentWith
values (
		curdate(),
		curtime(),
		'1232131241',
		'2874-06-07',
		'12:30:00',
		'15:30:00',
		'1234567890'
		);

# qPa5 - can cancel an appointment they made, by looking at the list of self booked appointments
#jon - checked: entered, add variables
delete from MakesAppointmentWith 
where
	CareCardNum = '1234567890' and
	TimeBlockDate = '2015-04-03' and
	StartTime = '09:00:00';


# ----can view upcoming appointments, on a certain date(optional) and during a certain time(optional)
# 3 queries
# 1) qPa6a - view upcoming appts
#jon - checked: entered, add variables
select MakeApptW.StartTime, MakeApptW.EndTime, MakeApptW.TimeBlockDate,
		CONCAT(D.FirstName, " ", D.LastName) as "Doctor",  
	CONCAT(MakeApptW.TimeMade, " ", MakeApptW.DateMade) as "Appointment made on "
from MakesAppointmentWith MakeApptW, Doctor D, Patient P
where MakeApptW.LicenseNum = D.LicenseNum and
		MakeApptW.CareCardNum = P.CareCardNum and
		P.CareCardNum = '1234567890';

# 2) qPa6b - view appts on a certain date(optional), sample date = '2015-04-03'
select MakeApptW.StartTime, MakeApptW.EndTime, MakeApptW.TimeBlockDate,
		CONCAT(D.FirstName, " ", D.LastName) as "Doctor",  
	CONCAT(MakeApptW.TimeMade, " ", MakeApptW.DateMade) as "Appointment made on "
from MakesAppointmentWith MakeApptW, Doctor D, Patient P
where MakeApptW.LicenseNum = D.LicenseNum and
		MakeApptW.CareCardNum = P.CareCardNum and
		P.CareCardNum = '1234567890' and
		MakeApptW.TimeBlockDate = '2015-04-03';
# 3) qPa6c - view appts during a certain time(optional)
select MakeApptW.StartTime, MakeApptW.EndTime, MakeApptW.TimeBlockDate,
		CONCAT(D.FirstName, " ", D.LastName) as "Doctor",  
	CONCAT(MakeApptW.TimeMade, " ", MakeApptW.DateMade) as "Appointment made on "
from MakesAppointmentWith MakeApptW, Doctor D, Patient P
where MakeApptW.LicenseNum = D.LicenseNum and
		MakeApptW.CareCardNum = P.CareCardNum and
		P.CareCardNum = '1234567890' and
		MakeApptW.StartTime >=  '09:00:00'  and
		MakeApptW.StartTime <=  '11:00:00';



# qPa7 - can (quickly)check if he/she took a certain drug before
#----can view a list of drugs that interact with a specific drug
# example query: select the generic name of all drugs that interact with Ibuprofen
# jon - checked: entered,  add variables
select dGenericName
from InteractsWith
where iGenericName like '%Ibuprofen%';

# qPa8 - can input a prescription ID and view a list of drugs that interact with this prescription
	/*
	# example: find all drugs that interact with the drug prescribed in prescription 99
	select
	from Prescription p, InteractsWith iw
	where p.
	*/ -- ^Don't think this query is possible given our schema -Alfred
	# jon - checked: entered, add variables
select distinct IW.iBrandName as "Brand name" , IW.iGenericName as "Generic name"
from Prescription P, InteractsWith IW, Includes I, Drug D1, Drug D2
where 	P.PrescriptID LIKE '0001' and
		P.PrescriptID = I.PrescriptID and
		I.BrandName = D1.BrandName and
		I.GenericName = D1.GenericName and

		IW.dBrandName = D1.BrandName and
		IW.dGenericName = D1.GenericName and

		IW.iBrandName != D1.BrandName and
		IW.iGenericName != D1.GenericName;


# qPa9 - can view status of prescription pick up (ready or not for pickup)
#jon: checked: entered, works
select *
from Prescription
where ReadyForPickup=1;

# qPa10----Generate a report about what prescriptions a patient is currently using, 
# 	when they were prescribed, and which doctor prescribed them, as well as which pharmacies have them in stock currently
# 	the last part is impossible, we dont have that kind of info
# 	and we cant differentiate between prescriptions patient took vs taking now
# 	generate a report about prescriptions for a patient, when they were prescribed, which doctor prescribed them
# 	the most recent on the top
	
# 	sample patient license num: '1234567890'
# jon: checked: entered, add variables

select distinct Pr.PrescriptID as "Prescription ID", (Pr.date_prescribed) as "Date prescribed", 
        CONCAT(D.FirstName, " ", D.LastName) as "Prescribed by", CONCAT (Dr.BrandName, " ", Dr.GenericName) as Drug,
        Pr.dosage as "Drug dosage",  Pr.refills as "Refills"
from Patient P, Prescription Pr, Doctor D, Pharmacy Pm,  Includes I, Drug Dr
where 	P.CareCardNum LIKE '1234567890' and
		P.CareCardNum = Pr.CareCardNum and 
		Pr.LicenseNum = D.LicenseNum and 
		I.PrescriptID = Pr.PrescriptID and
		I.BrandName = Dr.BrandName and
		I.GenericName = Dr.GenericName and
		Pr.refills > 0

order by Pr.date_prescribed desc;

        


# qPa11--- second analogous report, but for previous prescriptions (not current)
# jon: checked: entered, add variables
select distinct Pr.PrescriptID as "Prescription ID", (Pr.date_prescribed) as "Date prescribed", 
		CONCAT(D.FirstName, " ", D.LastName) as "Prescribed by", CONCAT (Dr.BrandName, " ", Dr.GenericName) as Drug,
		Pr.dosage as "Drug dosage",  Pr.refills as "Refills"
from Patient P, Prescription Pr, Doctor D, Pharmacy Pm,  Includes I, Drug Dr
where 	P.CareCardNum LIKE '1234567890' and
		P.CareCardNum = Pr.CareCardNum and 
		Pr.LicenseNum = D.LicenseNum and 
		I.PrescriptID = Pr.PrescriptID and
		I.BrandName = Dr.BrandName and
		I.GenericName = Dr.GenericName and
		Pr.refills = 0
order by Pr.date_prescribed desc;


########User: Doctors
# qD1 - can update personal information about him/herself
# jon: checked: entered, add variables
update Doctor
set
	FirstName = 'bla',
	LastName = 'bla',
	Address = 'bla',
	PhoneNumber = 7789877680,
	Type = "Super cool doctor type"
where
	LicenseNum = '1232131241';


# qD2 can prescribe a drug
#chris--need to put variable names later
# jon: checked: entered, add variables
insert into Prescription
values ('doctorIDvariable','?','?' ,'?' ,'?' , 0, NOW());


#same as the patient ^^^
#can view a list of pharmacies that are open at the moment
	# already done


#can view a list of pharmacies that are open on a certain date and time(optional)
# pD3 & pD4
	# already done
# jon -checked: entered, reformat

#can input an address and a radius and as a result, can view a list of pharmacies that are open at the moment , within the indicated radius of the indicated address
	# too hard

#can view a list of all appointments for any picked date and any picked time
# qD5
# jon -checked: entered, add variables
select MakeApptW.StartTime, MakeApptW.EndTime, MakeApptW.TimeBlockDate,
		CONCAT(P.FirstName, " ", P.LastName) as "Patient",  
	CONCAT(MakeApptW.TimeMade, " ", MakeApptW.DateMade) as "Appointment made on "
from MakesAppointmentWith MakeApptW, Doctor D, Patient P
where MakeApptW.LicenseNum = D.LicenseNum and
		MakeApptW.CareCardNum = P.CareCardNum and
		D.LicenseNum  = '1232131241'
order by MakeApptW.StartTime, MakeApptW.EndTime, MakeApptW.TimeBlockDate; 
# the order by seems to be unnecessary, but ill leave it here just in case

# qD6
# jon -checked: entered, add variables
# 2) view appts on a certain date(optional), sample date = '2015-04-03'
select MakeApptW.StartTime, MakeApptW.EndTime, MakeApptW.TimeBlockDate,
		CONCAT(P.FirstName, " ", P.LastName) as "Patient",  
	CONCAT(MakeApptW.TimeMade, " ", MakeApptW.DateMade) as "Appointment made on "
from MakesAppointmentWith MakeApptW, Doctor D, Patient P
where MakeApptW.LicenseNum = D.LicenseNum and
		MakeApptW.CareCardNum = P.CareCardNum and
		D.LicenseNum  = '1232131241' and
		MakeApptW.TimeBlockDate = '2015-04-03';

# qD7
# jon -checked: entered, add variables
# 3) view appts during a certain time(optional)
select MakeApptW.StartTime, MakeApptW.EndTime, MakeApptW.TimeBlockDate,
		CONCAT(P.FirstName, " ", P.LastName) as "Patient",  
	CONCAT(MakeApptW.TimeMade, " ", MakeApptW.DateMade) as "Appointment made on "
from MakesAppointmentWith MakeApptW, Doctor D, Patient P
where MakeApptW.LicenseNum = D.LicenseNum and
		MakeApptW.CareCardNum = P.CareCardNum and
		D.LicenseNum  = '1232131241' and
		MakeApptW.StartTime >=  '09:00:00'  and
		MakeApptW.StartTime <=  '11:00:00';

#can register a patient who requested his/her services
	# nope

# qD8 - can view personal information about a patient 
# jon -checked: entered, add variables
# example query: view all data about patient number 999
select *
from Patient
where CareCardNum=999;

# qD9 -can view a list of previous prescriptions for a certain patient
# jon - checked: entered, ensure only for this doctor's patients
#	same as Q1


# qD10 - can view a list of previous drugs taken by a certain patient
#chris
# jon - checked: entered, ensure only for this doctor's patients
select I.GenericName
from Prescription Pr, Patient P, Includes I
where P.CareCardNum= '1234 456 789' AND Pr.CareCardNum=P.CareCardNum AND I.PrescriptID=Pr.PrescriptID;


# qD11 - can check if a certain drug was taken in the past by a certain patient
# jon - checked: entered, ensure only for this doctor's patients
select distinct Pr.PrescriptID as "Prescription ID", (Pr.date_prescribed) as "Date prescribed", 
		CONCAT(D.FirstName, " ", D.LastName) as "Prescribed by", CONCAT (Dr.BrandName, " ", Dr.GenericName) as Drug,
		Pr.dosage as "Drug dosage"
from Patient P, Prescription Pr, Doctor D, Pharmacy Pm,  Includes I, Drug Dr
where 	P.CareCardNum LIKE '1234567890' and
		P.CareCardNum = Pr.CareCardNum and 
		Pr.LicenseNum = D.LicenseNum and 
		I.PrescriptID = Pr.PrescriptID and
		I.BrandName = Dr.BrandName and
		I.GenericName = Dr.GenericName and
		Pr.refills = 0
order by Pr.date_prescribed desc;


# qD12 - can view a list of drugs that interact with a specific drug  (same as patient)
#chris
# jon - checked: entered, column names are not working
select I.iGenericName
from InteractsWith I, Drug D
where D.GenericName=I.dGenericName AND D.CompanyName=I.dCompanyName;

#notified when patients cancel an appointment
	# hmmm? probs we can just do this at the application level, idk

# qD13
#can view a list of past appointments by a certain patient
#chris
# jon - checked: entered, works, but need to select more attributes?
select M.DateMade
from MakesAppointmentWith M, Doctor D
where D.LicenseNum=M.LicenseNum;

# qD14----Generate a report about which prescriptions a doctor has
#   previously prescribed, and to whom the prescriptions were prescribed, as well as which pharmacy filled the prescription
# 	sample, doctor's license num = '1232131241'
# jon - checked: entered, works, add variables
select Pr.PrescriptID, CONCAT(P.FirstName, " ", P.LastName) as PatientName, CONCAT (Dr.BrandName, " ", Dr.GenericName) as Drug, CONCAT(Pm.Address, ", ", Pm.Name) as PharmacyDescription 
from Prescription Pr, Doctor D, Patient P, Pharmacy Pm, OrderedFrom O, Includes I, Drug Dr
where 	Pr.LicenseNum = D.LicenseNum and
		Pr.CareCardNum = P.CareCardNum and 
		O.PrescriptID = Pr.PrescriptID and 
		O.PharmacyAddress = Pm.Address and 
		I.PrescriptID = Pr.PrescriptID and
		I.BrandName = Dr.BrandName and
		I.GenericName = Dr.GenericName and
		D.LicenseNum LIKE '1232131241';


# qD15 - show the average number of refills for a certain drug
# jon - checked: entered, works
select CONCAT(Dr.BrandName, " ", Dr.GenericName) as "Drug", AVG(P.Refills) as "Average number of refills"
from Prescription P, Drug Dr, Includes I
where P.PrescriptID = I.PrescriptID and 
		I.BrandName = Dr.BrandName and 
		I.GenericName = Dr.GenericName
group by Dr.BrandName, Dr.GenericName
order by AVG(P.Refills) desc, Dr.BrandName, Dr.GenericName;


# qD16 - select patients who ordered all products by company name = Pfizer
# jon - checked: entered, add variables
select Pa.CareCardNum, Pa.FirstName
from Patient Pa
Where NOT EXISTS
     (Select *
      from Drug D
      Where D.CompanyName LIKE 'Pfizer'
      AND NOT EXISTS
      (Select * 
            From Prescription P, Includes I
            WHERE P.PrescriptID = I.prescriptID and 
            		I.BrandName = D.BrandName and
            		P.CareCardNum = Pa.CareCardNum));




