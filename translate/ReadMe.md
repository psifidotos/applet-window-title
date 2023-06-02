Before translating, make sure to run `merge.sh` to update/refresh the template.

In order to create a new locale, copy `template.pot` as LANG`.po`, where LANG is an ISO 639-1 code of your language.
Fill out the metadata and translate each `msgid` into `msgstr`. Check uk.po for an example.

After you have finished translating, run `build.sh` to compile your locale.

|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |      49 |       |
| ru       |   49/49 |  100% |
| uk       |   49/49 |  100% |
