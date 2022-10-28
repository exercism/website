import { Credits } from '@/components/common'
import { useHighlighting } from '@/hooks'
import React from 'react'
import { Article } from '../DigDeeper'

export function ArticleSnippet({ article }: { article: Article }): JSX.Element {
  const codeBlockRef = useHighlighting<HTMLPreElement>()

  return (
    <a
      href={article.links.self}
      className="bg-white shadow-base rounded-8 px-20 py-16 mb-16"
    >
      <pre
        className="border-1 border-lightGray rounded-8 p-16 mb-16"
        ref={codeBlockRef}
      >
        <div
          className="c-cli-walkthrough"
          dangerouslySetInnerHTML={{ __html: article.snippetHtml }}
        />
      </pre>
      <h5 className="text-h5 mb-2">{article.title}</h5>
      <p className="text-p-base text-textColor6 mb-12">{article.blurb}</p>
      <Credits
        topLabel={'author'}
        topCount={article.numAuthors}
        bottomLabel={'contributor'}
        bottomCount={article.numContributors}
        users={article.users}
      />
    </a>
  )
}
