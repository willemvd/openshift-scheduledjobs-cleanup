# OpenShift v3 Scheduledjobs Cleanup

Problem with scheduled jobs in OpenShift is that they will not be removed even if they successfully ended.
To prevent lots of finished jobs, you can remove those with the use of this Docker image.

It will check for all jobs that have successfully ended and will remove these using the oc cli.
