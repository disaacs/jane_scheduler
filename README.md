# Scheduler

This scheduler repo is my submission for https://github.com/SeeJaneHire/assignment-Dave-Isaacs. 

There may be other slightly similar repos, but this one is mine 😄

This assignment was fun, thanks! Keep reading to see how to setup the app and run the tests. You can also skip to the end to read some of my development notes.

Cheers!

Dave Isaacs

## Requirements

The scheduler app requires ruby version 3.2.0.

## Setup

To get the scheduler app setup, first clone this repo and cd into its directory. Then run the following commands:

```
$ bundle install
$ rails db:setup
```

## Running the tests

To run the tests, simply run the `rspec` command from the project directory. For example:

```
$ rspec
.......................

Finished in 0.25332 seconds (files took 1.26 seconds to load)
23 examples, 0 failures
```

## Running the server

If you really want to, you can start the scheduler server locally with the command
```
$ rails server
```
and then send requests to it on localhost:3000.


## Assumption made during development

During the development of this app, I've made the following assumptions

1. We are building an API only app.
   - No front end required.
   - JSON-based API
2. Pagination is not necessary, since we are dealing with only a single day a a time.
3. There is only 1 practitioner.
   - In other words, we don't have to worry about whose time is being booked.
4. The assignment states “You do not need to include a database…” by which I presume you do not need to SEED a database with dummy data. A database is needed to store appointments and such.
5. Times will be assumed to be UTC. This is a biggie, since it sidesteps timezone and DST issues. This is impractical in practice, but great for the purposes of this exercise.
6. No security is necessary (e.g., user login, authorization). Again, impractical in practice, but it lets us focus on the purpose of the assignment.

## About the Schedule API

This API contains 3 endpoints.

- GET /appointments - Returns a list of available appointments for a specified date and appointment type
- POST /appointments - Creates an appoinment of the specified type, on the specified date and time, for the specified patient name.
- GET /schedule - Returns a list of appointments booked for the specified date.

### GET /appointments
Return a list of available appointments for a specified date and appointment type.
#### Required parameters
- `date` - A parseable date string. For example `2023-09-30`.
- `type` - The appointment type. One of `initial`, `standard`, `checkin`.

#### Response
A JSON list of appointments. For example:
```
[
  {
    "starts_at": "2023-09-30T09:00:00.000Z",
    "type": "initial",
    "ends_at": "2023-09-30T10:30:00.000Z"
  },
  {
    "starts_at": "2023-09-30T09:30:00.000Z",
    "type": "initial",
    "ends_at": "2023-09-30T11:00:00.000Z"
  }
]
```

### POST /appointments
Create an appointment.

#### Required JSON body
```
{
  "appointment": {
    "starts_at": "<parseable datetime>",
    "type": "<one of initial, standard, or checkin>",
    "patient_name": "<the patient's name>"
  }
}
```
For example
```
{
  "appointment": {
    "starts_at": "2023-09-30 10:00",
    "type": "initial",
    "patient_name": "Alice"
  }
}
```

#### Response
A JSON representation of the appointment just created. For example
```
{
  "id": 1,
  "starts_at": "2023-09-30T09:30:00.000Z",
  "type": "initial",
  "patient_name": "Alice",
  "created_at": "2023-09-29T15:08:28.949Z",
  "updated_at": "2023-09-29T15:08:28.949Z",
  "ends_at": "2023-09-30T11:00:00.000Z"
}
```

### GET /schedule
Get the list of scheduled appointments.

#### Required parameters
- `date` - A parseable date string. For example `2023-09-30`.

#### Response
A JSON list of scheduled appointments, ordered by `starts_at` ascending. For example
```[
  {
    "id": 1,
    "starts_at": "2023-09-30T09:30:00.000Z",
    "type": "initial",
    "patient_name": "Alice",
    "created_at": "2023-09-29T15:08:28.949Z",
    "updated_at": "2023-09-29T15:08:28.949Z",
    "ends_at": "2023-09-30T11:00:00.000Z"
  },
  {
    "id": 2,
    "starts_at": "2023-09-30T13:00:00.000Z",
    "type": "standard",
    "patient_name": "Bob",
    "created_at": "2023-09-29T15:13:01.140Z",
    "updated_at": "2023-09-29T15:13:01.140Z",
    "ends_at": "2023-09-30T14:00:00.000Z"
  }
]
```

## Development notes

### Appointment model

#### Validations
The Appointment model is where most of the application validation happens. Most of the validations are straightforward, though the validations to check the `starts_at` have some involved time-based arithmetic.

Validating whether or not an appointment overlaps another appointment gets interesting. I decided to tackle this by introducing the concept of time-slots. A 9 AM - 5 PM day can be divided into 16 time slots, numbered 0 to 15. For any given appointment it is relatively easy to calculate which time slots it occupies and represent it as an array (see the `time_slots` method). Therefore to figure out whether or not a new appointment overlaps an existing appointment, all that is required is to build an array of occupied time slots from the existing appointments, and intersect that with the new appointment time slots. If there is any intersection, then there is an overlap.

It occurs to me that the Appointments model may have been better designed by NOT using the `starts_at` datetime column, and instead using a `starting_slot` column. This would neatly sidestep the classic issues introduced by timezones and DST. Anyway, I am commited now—I don't have time to refactor the Appointments class to use `starting_slot` instead of `starts_at` 😛

I also just realized I did not include any validation preventing creating appointments in the past. Ooops!

### AppointmentsController
I created an `appointment_params` method to filter the params received when creating a new appointment. It can be argued that this not necessary—strong params are most useful when updating resources, but updates are not in scope of this assignment. No matter, I added them anyway.

The `index` method, which services the `GET /appointments` endpoint, is rather brute force. It calculates the available appointments by creating every possible appointment in a day and checking each for validity. This could be optimized by
1. Don't bother to check appointments that would overlap 5 PM.
2. Don't bother to check appointments that start in an already occupied time slot.

I unfortunately did not have enough free time to investigate these optimizations.

Also, I believe this method will blow up if you pass in an invalid date string or appointment type. An additional layer of validation is needed to handle such errors gracefully.




