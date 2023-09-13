# BeSTGRID@HOME


Contact Person: Dr Chris Messom (BeSTGRID Massey University Lead)

- We're aiming to have BestGRID host some BOINC projects. The idea will be that one of the BestGRID servers will keep track of the workload and distribute the jobs.

- BOINC is mainly designed for public computing and seems to have built in features for testing results (sending the same job to multiple machines and checking results are the same) which is obviously required for the public machines but probably not needed on our "trusted" campus machines.

- In the background we're also investigating Condor for the campus machines which offers the ability to submit any jobs (rather than the large project based BOINC which tends to have the same jobs with different data (normally close to an infinite supply of data such as SETI@HOME Folding@HOME etc))

- Some people are also looking at a combination of Condor and BOINC, running Condor jobs when researchers submit them and when there is no on demand work, running the BOINC jobs. Both Condor and BOINC track the workload, so it should be fairly easy to evaluate cost effectiveness over time, especially in terms of power etc.
