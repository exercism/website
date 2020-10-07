# Schema Changes

These are deliberate schema changes that need to be handled during ETL.

## Submission Files

- Need `uuid` generating. Consider pregenerating a whole load and going through to make this quicker.
- Rename `file_contents_digest` to `digest`
- `file_contents` need uploading to s3 rather than being stored.
