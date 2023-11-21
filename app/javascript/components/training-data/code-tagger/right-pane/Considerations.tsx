import React from 'react'

export default function Considerations(): JSX.Element | null {
  return (
    <p className="flex items-center justify-center font-medium text-16 leading-[24px] py-8 px-16 border-2 border-orange rounded-8 bg-bgCAlert text-textCAlert whitespace-nowrap my-16">
      Please&nbsp;
      <a
        href="/docs/building/tooling/analyzers/tags"
        target="_blank"
        rel="noreferrer"
        className="!text-textCAlertLabel underline"
      >
        read the docs
      </a>
      &nbsp;before tagging solutions.
    </p>
  )
}
