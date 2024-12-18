-- AIRPLANE
INSERT INTO AIRPLANE (airplane_id, seating_arrangement, luggage_space, network_coverage)
VALUES (1, '3-3', 'Standard', 'Wi-Fi');

-- FLIGHT
INSERT INTO FLIGHT (flight_code, airplane_id, flight_details)
VALUES ('QF123', 1, 'Sydney to Melbourne');

-- PASSENGER
INSERT INTO PASSENGER (passenger_id, title, first_name, last_name, date_of_birth, email, citizenship, passport_number)
VALUES (1, 'Mr', 'John', 'Doe', TO_DATE('1990-05-15', 'YYYY-MM-DD'), 'john.doe@example.com', 'Australian', 'A1234567');

-- INSURANCE
INSERT INTO INSURANCE (insurance_type, cost, coverage_rules)
VALUES ('Basic', 50.00, 'Standard coverage');

-- FARETYPE
INSERT INTO FARETYPE (fare_type, cancel_charge, changes_charge, baggage, status_credit)
VALUES ('Economy', 100.00, 50.00, 'Checked baggage', 'No credit');

-- BOARDINGPASS
INSERT INTO BOARDINGPASS (boarding_pass_id, boarding_gate, passenger_name, flight_code, seat_number, change_changetype)
VALUES (1, 'A12', 'John Doe', 'QF123', '15A', NULL);

-- FREQUENT_FLYER
INSERT INTO FREQUENT_FLYER (membership_number, mobile_number, pin, email, first_name, last_name, date_of_birth, joining_date)
VALUES (1234567, '+61412345678', '1234', 'john.doe@example.com', 'John', 'Doe', TO_DATE('1990-05-15', 'YYYY-MM-DD'), TO_DATE('2020-01-01', 'YYYY-MM-DD'));

-- QUANTAS_CLUB
INSERT INTO QUANTAS_CLUB (membership_number, join_date, expiry_date, joining_fee)
VALUES (9876543, TO_DATE('2022-06-01', 'YYYY-MM-DD'), TO_DATE('2024-05-31', 'YYYY-MM-DD'), 500.00);

-- BOOKING
INSERT INTO BOOKING (booking_ref, comm_email, booking_agent, status, num_passenger, departure_city, destination_city, type, passenger_id, insurance_type)
VALUES ('B123456', 'booking@example.com', 'Agent XYZ', 'Confirmed', 1, 'Sydney', 'Melbourne', 'One-way', 1, 'Basic');

-- FLIGHT_SCHEDULE
INSERT INTO FLIGHT_SCHEDULE (flight_code, travel_date, start_time, dest_time, travel_time, origin_city, destination_city, availability)
VALUES ('QF123', TO_DATE('2024-07-01', 'YYYY-MM-DD'), TO_DATE('09:00:00', 'HH24:MI:SS'), TO_DATE('10:30:00', 'HH24:MI:SS'), '1h 30m', 'Sydney', 'Melbourne', 150);

-- TRIPDETAILS
INSERT INTO TRIPDETAILS (booking_ref, flight_code, passenger_id, fare_type, meal_option, baggage, seat_number, f_flyer_point, travel_date)
VALUES ('B123456', 'QF123', 1, 'Economy', 'Regular', 'Checked', '15A', 0, TO_DATE('2024-07-01', 'YYYY-MM-DD'));

-- BOOKINGRECEIPT
INSERT INTO BOOKINGRECEIPT (receipt_id, booking_ref, total_payment, flight_cost, ex_baggage_cost, insurance_cost, discount, tax, payment_status)
VALUES (1, 'B123456', 500.00, 400.00, 0.00, 50.00, 0.00, 50.00, 'Paid');

-- PAYMENT
INSERT INTO PAYMENT (payment_MID, pay_type, pay_details)
VALUES (1234, 'Credit Card', 'Visa 1234******5678');

-- CHANGEBOOKRECEIPT
INSERT INTO CHANGEBOOKRECEIPT (receipt_id, fare_difference, penalty)
VALUES (2, 100.00, 50.00);

-- PAIDBY
INSERT INTO PAIDBY (receipt_id, payment_MID, amount)
VALUES (1, 1234, 500.00);


-- CHECKIN
INSERT INTO CHECKIN (booking_ref, flight_code, passenger_id, boarding_pass_id)
VALUES ('B123456', 'QF123', 1, 1);

-- ENROLL
INSERT INTO ENROLL (passenger_id, membership_number)
VALUES (1, 1234567);

-- PAID_CHANGE
INSERT INTO PAID_CHANGE (receipt_id, booking_ref)
VALUES (2, 'B123456');

-- PAID
INSERT INTO PAID (receipt_id, booking_ref)
VALUES (1, 'B123456');

-- BECOMES
INSERT INTO BECOMES (membership_number_FF, membership_number_QC)
VALUES (1234567, 9876543);

-- ACC_HISTORY
INSERT INTO ACC_HISTORY (booking_ref, points_earned, points_used, points_balance, acc_date, membership_number)
VALUES ('B123456', 500, 0, 500, TO_DATE('2024-07-01', 'YYYY-MM-DD'), 1234567);



#Procedure to list flights available for a given destination and origin city:

CREATE OR REPLACE PROCEDURE list_flights(
    p_origin_city VARCHAR2,
    p_destination_city VARCHAR2
)
IS
    CURSOR flight_cur IS
        SELECT f.flight_code, fs.travel_date, fs.start_time, fs.dest_time, fs.travel_time, fs.availability
        FROM FLIGHT_SCHEDULE fs
        JOIN FLIGHT f ON fs.flight_code = f.flight_code
        WHERE fs.origin_city = p_origin_city
        AND fs.destination_city = p_destination_city
        AND fs.travel_date >= SYSDATE
        ORDER BY fs.travel_date, fs.start_time;
BEGIN
    FOR flight_rec IN flight_cur LOOP
        DBMS_OUTPUT.PUT_LINE('Flight Code: ' || flight_rec.flight_code);
        DBMS_OUTPUT.PUT_LINE('Travel Date: ' || flight_rec.travel_date);
        DBMS_OUTPUT.PUT_LINE('Start Time: ' || flight_rec.start_time);
        DBMS_OUTPUT.PUT_LINE('Destination Time: ' || flight_rec.dest_time);
        DBMS_OUTPUT.PUT_LINE('Travel Time: ' || flight_rec.travel_time);
        DBMS_OUTPUT.PUT_LINE('Availability: ' || flight_rec.availability);
        DBMS_OUTPUT.PUT_LINE('----------------------------');
    END LOOP;
END;
/

#To use this procedure, call it with the desired origin and destination cities:
BEGIN
    list_flights('Sydney', 'Melbourne');
END;
/

#Function to get frequent flyer points balance for a given passenger
CREATE OR REPLACE FUNCTION get_ff_points_balance(
    p_passenger_id IN PASSENGER.passenger_id%TYPE
)
RETURN NUMBER
IS
    v_points_balance NUMBER;
BEGIN
    SELECT ah.points_balance
    INTO v_points_balance
    FROM ACC_HISTORY ah
    JOIN ENROLL e ON ah.membership_number = e.membership_number
    WHERE e.passenger_id = p_passenger_id
    ORDER BY ah.acc_date DESC
    FETCH FIRST 1 ROW ONLY;

    RETURN v_points_balance;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/


DECLARE
    v_points_balance NUMBER;
BEGIN
    v_points_balance := get_ff_points_balance(1);
    DBMS_OUTPUT.PUT_LINE('Frequent Flyer Points Balance: ' || v_points_balance);
END;
/