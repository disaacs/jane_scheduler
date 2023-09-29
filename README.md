# Scheduler

This scheduler repo is my submission for https://github.com/SeeJaneHire/assignment-Dave-Isaacs. 

There may be other slightly similar repos, but this one is mine 😄

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
6. No security is necessary (e.g., user login, authorization). Again, impractical in practice, but let us focus on the purpose of the assignment.

## About the Schedule API

This API contains 3 endpoints.

- GET /appointments - Returns a list of available appointments for a specified date and appointment type
- POST /appointments - Creates an appoinment of the specified type, on the specified date and time, for the specified patient name.
- GET /schedule - Returns a list of appointments booked for the specified date.

### GET /appointments
Return a list of available appointsment for a specified date and appointment type.
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

