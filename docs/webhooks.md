# Webhooks

## Push events

We receive a webhook for any push event in the GitHub repo.
The request is handled by `Webhooks::PushUpdatesController` which proxies to the `Webhooks::ProcessPushUpdate` command.

The `Webhooks::ProcessPushUpdate` checks to see if this is a special repo (e.g. website-copy, docs, blog) or a track repo.
A job is then queued for the event.
Pushes to any other repos are silently ignored.

The job then runs in the background and calls out to a corresponding class (e.g. `Git::SyncBlog.()`) which fetches the latest HEAD of the repo and then syncs whatever data needs updating.
For more complex repos (e.g. tracks) we actively check what has changed and only update the relevant bits, whereas for simple repos (e.g. the blog) we just check and update everything.

All commands/jobs/etc have corresponding test files that map 1-1.
