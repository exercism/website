import React from 'react'
import { TaskKnowledge } from '../../../types'

export const KnowledgeIcon = ({
  knowledge,
}: {
  knowledge: TaskKnowledge
}): JSX.Element => {
  switch (knowledge) {
    case 'none':
      return (
        <>
          <div className="dot" />
          <div className="dot" />
          <div className="dot" />
        </>
      )
    case 'elementary':
      return (
        <>
          <div className="dot filled" />
          <div className="dot" />
          <div className="dot" />
        </>
      )
    case 'intermediate':
      return (
        <>
          <div className="dot filled" />
          <div className="dot filled" />
          <div className="dot" />
        </>
      )
    case 'advanced':
      return (
        <>
          <div className="dot filled" />
          <div className="dot filled" />
          <div className="dot filled" />
        </>
      )
  }
}
