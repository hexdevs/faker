### Maintaining Faker

As maintainers of the gem, this is our guide. Most of the steps and guidelines in the Contributing document apply here, including how to set up your environment, write code to fit the code style, run tests, craft commits and manage branches. Beyond this, this document provides some details that would be too low-level for contributors.

If you're reviewing a PR, ask yourself:
> * Does it work as described? A PR should have a great description.
> * Is it understandable?
> * Is it well implemented?
> * Is it well tested?
> * Is it well documented?
> * Is it following the structure of the project?

## Managing libraries dependencies EOL

As a guideline for Ruby's End of Life (EOL) versions, a good heuristic (that's not too hard on maintainers) is to keep support for 1 EOL version.
In other words, once Ruby 3.0 is EOL, drop support for 2.7.
