-- AIRPLANE
CREATE TABLE AIRPLANE (
    airplane_id INT PRIMARY KEY,
    seating_arrangement VARCHAR(50),
    luggage_space VARCHAR(50),
    network_coverage VARCHAR(50)
);

-- FLIGHT
CREATE TABLE FLIGHT (
    flight_code VARCHAR(10) PRIMARY KEY,
    airplane_id INT,
    flight_details VARCHAR(100),
    FOREIGN KEY (airplane_id) REFERENCES AIRPLANE(airplane_id)
);

-- PASSENGER
CREATE TABLE PASSENGER (
    passenger_id INT PRIMARY KEY,
    title VARCHAR(10),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    email VARCHAR(100),
    citizenship VARCHAR(50),
    passport_number VARCHAR(20)
);

-- BOOKING
CREATE TABLE BOOKING (
    booking_ref VARCHAR(20) PRIMARY KEY,
    comm_email VARCHAR(100),
    booking_agent VARCHAR(50),
    status VARCHAR(20),
    num_passenger INT,
    departure_city VARCHAR(50),
    destination_city VARCHAR(50),
    type VARCHAR(20),
    passenger_id INT,
    insurance_type VARCHAR(50),
    FOREIGN KEY (passenger_id) REFERENCES PASSENGER(passenger_id),
    FOREIGN KEY (insurance_type) REFERENCES INSURANCE(insurance_type)
);

-- INSURANCE
CREATE TABLE INSURANCE (
    insurance_type VARCHAR(50) PRIMARY KEY,
    cost DECIMAL(10, 2),
    coverage_rules VARCHAR(100)
);

-- FARETYPE
CREATE TABLE FARETYPE (
    fare_type VARCHAR(20) PRIMARY KEY,
    cancel_charge DECIMAL(10, 2),
    changes_charge DECIMAL(10, 2),
    baggage VARCHAR(50),
    status_credit VARCHAR(50)
);

-- BOARDINGPASS
CREATE TABLE BOARDINGPASS (
    boarding_pass_id INT PRIMARY KEY,
    boarding_gate VARCHAR(10),
    passenger_name VARCHAR(100),
    flight_code VARCHAR(10),
    seat_number VARCHAR(10),
    change_changetype VARCHAR(50)
);

-- TRIPDETAILS
CREATE TABLE TRIPDETAILS (
    booking_ref VARCHAR(20),
    flight_code VARCHAR(10),
    passenger_id INT,
    fare_type VARCHAR(20),
    meal_option VARCHAR(20),
    baggage VARCHAR(50),
    seat_number VARCHAR(10),
    f_flyer_point INT,
    travel_date DATE,
    PRIMARY KEY (passenger_id),
    FOREIGN KEY (booking_ref) REFERENCES BOOKING(booking_ref),
    FOREIGN KEY (passenger_id) REFERENCES PASSENGER(passenger_id),
    FOREIGN KEY (fare_type) REFERENCES FARETYPE(fare_type),
    FOREIGN KEY (flight_code, travel_date) REFERENCES FLIGHT_SCHEDULE(flight_code, travel_date)
);

-- FREQUENT_FLYER
CREATE TABLE FREQUENT_FLYER (
    membership_number INT PRIMARY KEY,
    mobile_number VARCHAR(20),
    pin VARCHAR(10),
    email VARCHAR(100),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    joining_date DATE
);

-- QUANTAS_CLUB
CREATE TABLE QUANTAS_CLUB (
    membership_number INT PRIMARY KEY,
    join_date DATE,
    expiry_date DATE,
    joining_fee DECIMAL(10, 2)
);

-- FLIGHT_SCHEDULE
CREATE TABLE FLIGHT_SCHEDULE (
    flight_code VARCHAR(10),
    travel_date DATE,
    start_time DATE,
    dest_time DATE,
    travel_time VARCHAR(10),
    origin_city VARCHAR(50),
    destination_city VARCHAR(50),
    availability INT,
    PRIMARY KEY (flight_code, travel_date),
    FOREIGN KEY (flight_code) REFERENCES FLIGHT(flight_code)
);

-- BOOKINGRECEIPT
CREATE TABLE BOOKINGRECEIPT (
    receipt_id INT PRIMARY KEY,
    booking_ref VARCHAR(20),
    total_payment DECIMAL(10, 2),
    flight_cost DECIMAL(10, 2),
    ex_baggage_cost DECIMAL(10, 2),
    insurance_cost DECIMAL(10, 2),
    discount DECIMAL(10, 2),
    tax DECIMAL(10, 2),
    payment_status VARCHAR(20)
);

-- PAYMENT
CREATE TABLE PAYMENT (
    payment_MID INT PRIMARY KEY,
    pay_type VARCHAR(20),
    pay_details VARCHAR(100)
);

-- CHANGEBOOKRECEIPT
CREATE TABLE CHANGEBOOKRECEIPT (
    receipt_id INT PRIMARY KEY,
    fare_difference DECIMAL(10, 2),
    penalty DECIMAL(10, 2)
);

-- PAIDBY
CREATE TABLE PAIDBY (
    receipt_id INT,
    payment_MID INT,
    amount DECIMAL(10, 2),
    PRIMARY KEY (receipt_id, payment_MID),
    FOREIGN KEY (receipt_id) REFERENCES BOOKINGRECEIPT(receipt_id),
    FOREIGN KEY (payment_MID) REFERENCES PAYMENT(payment_MID)
);

-- CHECKIN
CREATE TABLE CHECKIN (
    booking_ref VARCHAR(20),
    flight_code VARCHAR(10),
    passenger_id INT,
    boarding_pass_id INT,
    PRIMARY KEY (booking_ref, flight_code, passenger_id, boarding_pass_id),
    FOREIGN KEY (booking_ref) REFERENCES BOOKING(booking_ref),
    FOREIGN KEY (flight_code) REFERENCES FLIGHT(flight_code),
    FOREIGN KEY (passenger_id) REFERENCES PASSENGER(passenger_id),
    FOREIGN KEY (boarding_pass_id) REFERENCES BOARDINGPASS(boarding_pass_id)
);

-- ENROLL
CREATE TABLE ENROLL (
    passenger_id INT,
    membership_number INT,
    PRIMARY KEY (passenger_id, membership_number),
    FOREIGN KEY (passenger_id) REFERENCES PASSENGER(passenger_id),
    FOREIGN KEY (membership_number) REFERENCES FREQUENT_FLYER(membership_number)
);

-- PAID_CHANGE
CREATE TABLE PAID_CHANGE (
    receipt_id INT,
    booking_ref VARCHAR(20),
    PRIMARY KEY (receipt_id, booking_ref),
    FOREIGN KEY (receipt_id) REFERENCES CHANGEBOOKRECEIPT(receipt_id),
    FOREIGN KEY (booking_ref) REFERENCES BOOKING(booking_ref)
);

-- PAID
CREATE TABLE PAID (
    receipt_id INT,
    booking_ref VARCHAR(20),
    PRIMARY KEY (receipt_id, booking_ref),
    FOREIGN KEY (receipt_id) REFERENCES BOOKINGRECEIPT(receipt_id),
    FOREIGN KEY (booking_ref) REFERENCES BOOKING(booking_ref)
);

-- BECOMES
CREATE TABLE BECOMES (
    membership_number_FF INT,
    membership_number_QC INT,
    PRIMARY KEY (membership_number_FF, membership_number_QC),
    FOREIGN KEY (membership_number_FF) REFERENCES FREQUENT_FLYER(membership_number),
    FOREIGN KEY (membership_number_QC) REFERENCES QUANTAS_CLUB(membership_number)
);

-- ACC_HISTORY
CREATE TABLE ACC_HISTORY (
    booking_ref VARCHAR(20),
    points_earned INT,
    points_used INT,
    points_balance INT,
    acc_date DATE,
    membership_number INT,
    PRIMARY KEY (booking_ref),
    FOREIGN KEY (membership_number) REFERENCES FREQUENT_FLYER(membership_number)
);

CREATE TRIGGER add_ff_points
AFTER INSERT ON BOARDINGPASS
FOR EACH ROW
DECLARE
    ff_membership_number INT;
    booking_ref_var VARCHAR(20);
BEGIN
    SELECT td.booking_ref INTO booking_ref_var
    FROM TRIPDETAILS td
    WHERE td.passenger_id = NEW.passenger_id
    AND td.flight_code = NEW.flight_code
    LIMIT 1;
    
    
    SELECT e.membership_number INTO ff_membership_number
    FROM ENROLL e
    WHERE e.passenger_id = NEW.passenger_id
    LIMIT 1;
    
    INSERT INTO ACC_HISTORY (booking_ref, points_earned, points_used, points_balance, acc_date, membership_number)
    VALUES (booking_ref_var, 100, 0, 100, CURDATE(), ff_membership_number);
END;

CREATE TRIGGER reject_booking_status_change
BEFORE UPDATE ON BOOKING
FOR EACH ROW
DECLARE
    boarding_pass_count INT;
BEGIN
    SELECT COUNT(*) INTO boarding_pass_count
    FROM BOARDINGPASS bp
    JOIN TRIPDETAILS td ON bp.flight_code = td.flight_code
    WHERE td.booking_ref = :NEW.booking_ref;

    IF boarding_pass_count > 0 AND :NEW.status = 'cancelled' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot cancel booking as a boarding pass has been issued.');
    END IF;
END;
/