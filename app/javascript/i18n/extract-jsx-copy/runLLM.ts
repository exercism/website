import { GoogleGenAI } from '@google/genai'

export async function runLLM(prompt: string): Promise<string | undefined> {
  const apiKey = process.env.GOOGLE_GENAI_API_KEY
  const ai = new GoogleGenAI({ apiKey })

  const response = await ai.models.generateContent({
    model: 'gemini-2.5-flash',
    contents: prompt,
    config: {
      thinkingConfig: {
        thinkingBudget: 0,
      },
    },
  })

  return response.text
}
