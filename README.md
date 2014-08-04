# Pivotal Tracker Business Value

## Overview

Pivotal Tracker does a great job of tracking team velocity and completion of story-points, but from a broader perspective how can we track how well we're doing at delivering actual value to the customer or to our business? One approach we can us is to assign an estimate of the value we believe a feature delivers to our product, aside from effort.

### This project is a hack, it's not a product. It uses a ruby gem that relies on the soon-to-be-deprecated Pivotal Tracker API v3 and has almost zero error handling.

## Use

This is a sinatra app that I use hosted on Heroku. Users sign in using the Pivotal Tracker username / password and the resulting token is stored in a rack session.

All Projects the user has access to will be listed, the first one loads first automatically.

The typical Fibonacci estimate icons are listed for each story and can be used to estimate stories. Yellow stories are unestimated, grey have estimates and show the estimate as an icon to the left, just like Pivotal Tracker story points.
