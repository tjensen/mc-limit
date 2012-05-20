MC-Limit
========

Minecraft Limiter (mc-limit) launches Minecraft in offline mode
and automatically terminates the game after it has been played for
a pre-determined amount of time.

## Requirements

* Minecraft (http://minecraft.net/download)
* Java VM (http://java.com/download)
* Ruby 1.9.x (http://ruby-lang.org/en/downloads)

## How to install it

TBD

## How to run it

The utility uses environment variables for its configuration.
Set the `DEFAULT_MC_LIMIT` variable to equal the default number of
minutes of Minecraft play to allow per day.  If the variable is not
set, the default time limit will be 30 minutes.

Run "ruby \path\to\mc-limit.rb" to launch Minecraft.  I recommend
creating a desktop shortcut to make it easier to run.

## Security

This utility is by no means hacker-proof.  Any curious child (or
adult) who is literate and moderately skilled with computers is
capable of discovering how to defeat the time limit.  I consider it
a challenge for my kids.

## To-Do List

* Make it easy to install as a gem.
* Add a "parent" UI for adjusting the current day's remaining play
  time.
* Use a GUI toolkit (Shoes?) and be portable
* Display a timer while Minecraft is running that shows how much play
  time is left.
* Improve security.

