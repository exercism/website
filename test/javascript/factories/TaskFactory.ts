import { Task } from '../../../app/javascript/components/types'

export const createTask = (props: Partial<Task>): Task => ({
  title: 'Fix bugs',
  isNew: true,
  track: {
    title: 'Ruby',
    iconUrl: 'ruby',
  },
  tags: {
    action: 'create',
    type: 'docs',
    size: 'small',
    knowledge: 'elementary',
    module: 'analyzer',
  },
  links: {
    githubUrl: 'https://github.com/exercism/ruby/issues/123',
  },
  ...props,
})
