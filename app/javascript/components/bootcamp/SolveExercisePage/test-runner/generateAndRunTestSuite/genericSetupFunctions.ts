import { emojis } from './emoji'
export const genericSetupFunctions = {
  join: (...args: any[]) => args.join(''),
  randomEmoji: () => emojis[Math.floor(Math.random() * emojis.length)],
}
