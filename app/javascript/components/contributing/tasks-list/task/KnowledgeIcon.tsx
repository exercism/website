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
        <div className="knowledge-icon">
          <div className="dot" />
          <div className="dot" />
          <div className="dot" />
        </div>
      )
    case 'elementary':
      return (
        <div className="knowledge-icon">
          <div className="dot filled" />
          <div className="dot" />
          <div className="dot" />
        </div>
      )
    case 'intermediate':
      return (
        <div className="knowledge-icon">
          <div className="dot filled" />
          <div className="dot filled" />
          <div className="dot" />
        </div>
      )
    case 'advanced':
      return (
        <div className="knowledge-icon">
          <div className="dot filled" />
          <div className="dot filled" />
          <div className="dot filled" />
        </div>
      )
  }
}
