Connery
=======

A handy tool for converting data from AMEE datasets to calcJSON format

* [AMEE datasets](https://github.com/AMEE/datasets)
* [calcJSON](https://github.com/spatchcock/calcJSON)
* [calc-json-ruby](https://github.com/spatchcock/calc-json-ruby)

Doesn't handle 100% of the schema conversion right now, but does all the basics - inputs, contexts, and algorithms.

Run like:

ruby connery.rb /path/to/amee/dataset /path/to/output/with/basename

This will save the dataset in the first directory to basename.json and basename.csv in the 'with' directory.