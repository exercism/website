import { File } from '../../../app/javascript/components/types'
import { build } from '@jackfranklin/test-data-bot'

export const createFile = build<File>({
  fields: {
    filename: 'file.rb',
    content: 'class File\nend\n',
    digest: 'digest',
    type: 'exercise',
  },
})
