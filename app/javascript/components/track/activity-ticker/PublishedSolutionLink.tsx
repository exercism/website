import React from 'react'
export function PublishedSolutionLink({
  publishedSolutionUrl,
}: {
  publishedSolutionUrl: string
}) {
  return (
    <span className="inline-flex">
      {' '}
      <a
        href={publishedSolutionUrl}
        className="flex flex-row items-center font-semibold text-prominentLinkColor"
      >
        new solution
      </a>
      &nbsp;for&nbsp;
    </span>
  )
}
