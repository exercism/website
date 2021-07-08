import { useState, useCallback } from 'react'
import { DiscussionPostProps } from '../DiscussionPost'

export const usePostEditing = () => {
  const [editingPost, setEditingPost] = useState<DiscussionPostProps | null>(
    null
  )

  const handleEdit = useCallback((post) => {
    return () => setEditingPost(post)
  }, [])

  const handleEditCancel = useCallback(() => {
    setEditingPost(null)
  }, [])

  return { editingPost, handleEdit, handleEditCancel }
}
