import copy from 'copy-to-clipboard'

export const copyToClipboard = async (text: string): Promise<void> => {
  try {
    await copy(text)
  } catch (error) {
    if (process.env.NODE_ENV == 'production') {
      throw error
    }
  }
}
