# How the running of tests works

This file documents how students' tests are run and handled on the website side of things.

## Normal Submission

A normal test run starts in `Submission::Create` from which we call `Submission::TestRun::Init.(submission)`
This does two things:

1. It creates the tooling job, which starts the actual test-running process on our infrastructure.
2. It updates the status of various bits:
   - It sets the submission's status to be "queued"
   - If the submission is also the latest iteration's submission (ie it's just been submitted via the CLI) then the iteration statuses (latest + published) get set.

At this stage, the tests run, and then eventually `Submission::TestRun::Process` is called.
This does a few things.

1. Firstly, it creates the test run record.
2. It then checks to see what's happened and updates the status accordingly.
3. It then sets the solution statuses for published and iteration statuses if appropriate.
4. It broadcasts out via websockets to anyting listening, in either the editor or the iterations lists.

## Running HEAD test runs

Whenever the solution is updated (for example the published iteraton is changed), or its exercise is updated, we generally want to check whether a new HEAD test run should be run.
To do this we call `Solution::QueueHeadTestRun` (generally from the solution model in an `after_update_commit`, but also via other means we'll discuss in a future section.

This command is split into two sections: Updating the latest submission, and the latest published submission (which is what shows in the search indexes as whether the solution is up-to-date and passes the latest tests).
Both of these follow the same pattern:

- Check we're not using force (we're not)
- Check to see if we already have a passing/failing latest iteration and just use it if so
- Else queue up a latest test run.

For 99% of the time this whole process is a no-op.

# Automatically running HEAD tests.

When an exercise is updated and the important files change, we want to run the latests test to see if the exercise still passes.
This process is triggered via a `after_update_commit` in Exercise, which calls `Exercise::ProcessGitImportantFilesChanged`

This command acts in a couple of different ways.
The first is to look at whether the tests needs rerunning.
By default, they always do as the `git_important_files_hash` has changed.
(However, sometimes they don't - for example if the only changes are docs or the a maintainer has specifically said that they don't want to reurn the tests using the `[no important files changed]` flag in the commit.
See the next section for details on this).

Presuming we're ploughing ahead, firstly, all solutions are marked out of date in the search index.
We then enqueue test runs (via Sidekiq) for all test solutions for this exercise.
The big difference here is that we pass the new `git_sha` into the `Submission::TestRun::Init` command.
This causes the test runs to be associated with the latest version of the exercise not the original one.

When a test run comes back, it goes through the normal `Submission::TestRun::Process` process.
If the tests still pass, then we update the latest iteration and processed iteration.
This also has the side effect (via `Solution::SyncLatestIterationHeadTestsStatus`) of calling `Solution::AutoUpdateToLatestExerciseVersion`, which updates the `git_sha` and `git_important_files_hash` on the submission.

# Skipping head test runs
