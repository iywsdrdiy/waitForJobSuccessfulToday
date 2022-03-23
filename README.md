# waitForJobSuccessfulToday
Wait (or abend) until the named job completes successfully today.

The functions `getJobExecutionStatusToday` and `getProceedIfJobSuccessfulToday` could easily be amalgamated, but the former could be useful on its own.

`abendUntilJobSuccessfulToday` was written for someone who required one job to fail at a certain step if a second job had not successfully completed already that day, but then he got fed up restarting it manually when the second job *had* completed, so I wrote `waitForJobSuccessfulToday`.

Both these enable a kind of SEQ/PAR parallelism control à la [Occam](https://en.wikipedia.org/wiki/Occam_(programming_language)).  [`waitForJob`](https://github.com/iywsdrdiy/waitForJob), however, is more generic, not requiring the job to have completed just today but just not to be running or failed at the time of test.
