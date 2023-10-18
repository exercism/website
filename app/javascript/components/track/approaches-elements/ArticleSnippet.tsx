import React from 'react'
import { useHighlighting } from '@/hooks/use-syntax-highlighting'
import Credits from '@/components/common/Credits'
import { Article } from '../DigDeeper'

export function ArticleSnippet({ article }: { article: Article }): JSX.Element {
  const codeBlockRef = useHighlighting<HTMLPreElement>(article.snippetHtml)

  return (
    <a
      href={article.links.self}
      className="dig-deeper-snippet bg-backgroundColorA shadow-base rounded-8 px-20 py-16 mb-16"
    >
      <pre
        className="border-1 border-borderColor7 rounded-8 p-16 mb-16"
        ref={codeBlockRef}
      >
        <div
          className="overflow-hidden block"
          dangerouslySetInnerHTML={{ __html: article.snippetHtml }}
          style={{
            textOverflow: 'ellipsis',
            whiteSpace: 'nowrap',
          }}
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
        className="text-textColor1 font-semibold text-14"
      />
    </a>
  )
}
