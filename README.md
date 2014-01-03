erlang-scrapers
===============

Various web scrapers built in Erlang. Poor high quality code, but got the job done. Please note that these may well not work correctly now, but could be modified to acheive correct operation fairly easily. Each scraper was built to solve a specific problem and is now of little use to me, so I won't be updating them.

## buoy\_data ##

Grabs weather and wave information from ocean buoys through NOAA. The result is sent to STDOUT and displayed in the format:

```
{WaveDirection = {NorthSouth, WestEast}, WaveHeight, WindDirection = {Bearing, Speed}}
```

## coursera ##

Gigen the base URL for a course, returns a list of URLs for all the videos on the course. These URLs can then be passed to a downloader manager. Designed for a single course - no guarantees that it will function for others.

## ek ##

A scraper of player versus player loss data for EvE Online from the website 'eve-kill'. Outputs new losses as a kind of ticker.

## supermegacomics ##

Scraper for supermegacomics.com. Saves images into a subdirectory of the current working directory called 'comics'.

## xkcd ##

Scrapes all XKCD comics and saves them into an 'xkcd' subdirectory.
