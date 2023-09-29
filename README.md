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

