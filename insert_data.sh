#!/bin/bash

# Script to insert data from courses.csv and students.csv into students database

PSQL="psql -X --username=postgres --dbname=students --no-align --tuples-only -c"

echo $($PSQL "TRUNCATE majors, majors_courses, students, courses")

cat courses.csv | while IFS="," read MAJOR COURSE 
do
    if [[ $MAJOR != major ]]
    then
        # get major id
        MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'")
    
        # if not found
        if [[ -z $MAJOR_ID ]]
        then
            # insert major
            INSERT_MAJOR_RESULT=$($PSQL "INSERT INTO majors(major) VALUES('$MAJOR')")
            if [[ $INSERT_MAJOR_RESULT == "INSERT 0 1" ]]
            then
                echo Insert into majors, $MAJOR
            fi

            # get new major_id
            MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major = '$MAJOR'")
            
        fi
        
        # get course_id
        COURSE_ID=$($PSQL "SELECT course_id FROM courses WHERE course = '$COURSE'")

        # if not found
        if [[ -z $COURSE_ID ]]
        then
            # insert course
            INSERT_COURSE_RESULT=$($PSQL "INSERT INTO courses(course) VALUES('$COURSE')")
            if [[ $INSERT_COURSE_RESULT == "INSERT 0 1" ]]
            then
                echo Insert into courses, $COURSE
            fi

            # get new course_id
            COURSE_ID=$($PSQL "SELECT course_id FROM courses WHERE course = '$COURSE'")
            
        fi

    # insert into majors_courses
    INSERT_MAJORS_COURSES_RESULT=$($PSQL "INSERT INTO majors_courses VALUES($MAJOR_ID, $COURSE_ID)")
    if [[ $INSERT_MAJORS_COURSES_RESULT == "INSERT 0 1" ]]
    then
        echo Inserted into majors_courses, $MAJOR : $COURSE
    fi

    fi
done


cat students.csv | while IFS="," read FIRST LAST MAJOR GPA
do
    # check if FIRST isn't first_name then continue, else stop
    if [[ $FIRST != "first_name" ]]
    then
        # get student_id
        STUDENT_ID=$($PSQL "SELECT student_id FROM students WHERE first_name = '$FIRST' AND last_name = '$LAST'")

        # if not found
        if [[ -z $STUDENT_ID ]]
        then
            # get major_id
            MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major = '$MAJOR'")
            
            # set to null
            if [[ -z $MAJOR_ID ]]
            then
                MAJOR_ID=null
            fi

            # insert into students
            INSERT_STUDENT_RESULT=$($PSQL "INSERT INTO students(first_name, last_name, major_id, gpa) VALUES('$FIRST', '$LAST', $MAJOR_ID, $GPA)")
            if [[ $INSERT_STUDENT_RESULT == "INSERT 0 1" ]]
            then
                echo Inserted into students, $FIRST $LAST
            fi
        fi

    fi
done