import React from 'react'
export function PullRequestLink({
  pullRequest,
}: {
  pullRequest: Record<'htmlUrl', string>
}) {
  return (
    <span className="inline-flex">
      &nbsp;
      <a
        href={pullRequest.htmlUrl}
        className="flex flex-row items-center font-semibold text-prominentLinkColor"
      >
        Pull Request
      </a>
      .
    </span>
  )
}
