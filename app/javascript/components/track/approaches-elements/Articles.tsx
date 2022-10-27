import React, { useContext } from 'react'
import { ArticleSnippet, SectionHeader } from '.'
import { Article, DigDeeperDataContext } from '../DigDeeper'

export function Articles({ articles }: { articles: Article[] }): JSX.Element {
  const { exercise } = useContext(DigDeeperDataContext)
  return (
    <div className="flex flex-col">
      <SectionHeader
        title="Articles"
        description={
          articles.length > 0
            ? 'Explore more ideas about this exercise'
            : `There are no Articles for ${exercise.title}.`
        }
        icon="dig-deeper-gradient"
        className="mb-16"
      />

      {articles.length > 0 &&
        articles.map((i) => {
          return <ArticleSnippet key={i.title} article={i} />
        })}
    </div>
  )
}
