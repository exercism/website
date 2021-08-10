import React, { useCallback, Ref } from 'react'

export type ListItemAction = 'viewing' | 'editing'

export type ViewingComponentType<T> = {
  item: T
  onEdit: () => void
  itemRef?: Ref<HTMLDivElement>
  className?: string
}

export type EditingComponentType<T> = {
  item: T
  onUpdate?: (item: T) => void
  onDelete?: (item: T) => void
  onCancel: () => void
}

export type ListItemProps<T> = {
  item: T
  action: ListItemAction
  onUpdate?: (item: T) => void
  onDelete?: (item: T) => void
  onEdit?: () => void
  onEditCancel?: () => void
  className?: string
  ViewingComponent: React.ComponentType<ViewingComponentType<T>>
  EditingComponent: React.ComponentType<EditingComponentType<T>>
  itemRef?: Ref<HTMLDivElement>
}

export const ListItem = <T extends unknown>({
  item,
  action,
  onUpdate,
  onDelete,
  onEdit = () => null,
  onEditCancel = () => null,
  className = '',
  ViewingComponent,
  EditingComponent,
  itemRef,
}: ListItemProps<T>): JSX.Element => {
  const handleEdit = useCallback(() => {
    onEdit()
  }, [onEdit])
  const handleEditCancel = useCallback(() => {
    onEditCancel()
  }, [onEditCancel])

  const handleUpdate = useCallback(
    (item) => {
      if (!onUpdate) {
        return
      }

      onUpdate(item)
      onEditCancel()
    },
    [onEditCancel, onUpdate]
  )

  const handleDelete = useCallback(
    (item) => {
      if (!onDelete) {
        return
      }

      onDelete(item)
      onEditCancel()
    },
    [onDelete, onEditCancel]
  )

  switch (action) {
    case 'viewing':
      return (
        <ViewingComponent
          item={item}
          onEdit={handleEdit}
          itemRef={itemRef}
          className={className}
        />
      )
    case 'editing':
      return (
        <EditingComponent
          item={item}
          onUpdate={onUpdate ? handleUpdate : undefined}
          onDelete={onDelete ? handleDelete : undefined}
          onCancel={handleEditCancel}
        />
      )
  }
}
