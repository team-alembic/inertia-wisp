import { describe, it, expect } from 'vitest'
import { readFileSync } from 'fs'
import { resolve } from 'path'
import {
  ImageDataSchema,
  ContentBlockSchema,
  SlideSchema,
  SlideNavigationSchema,
} from '../src/schemas'

/**
 * Helper to load fixture file
 */
function loadFixture(filename: string): unknown {
  const fixturePath = resolve(__dirname, '../../shared/fixtures', filename)
  const fixtureJson = readFileSync(fixturePath, 'utf-8')
  return JSON.parse(fixtureJson)
}

describe('JSON Fixture Validation', () => {
  describe('ImageData', () => {
    it('validates image_data fixture against Zod schema', () => {
      const fixture = loadFixture('image_data.json')

      const result = ImageDataSchema.safeParse(fixture)

      expect(result.success).toBe(true)
      if (result.success) {
        expect(result.data.url).toBe('/images/gleam-logo.png')
        expect(result.data.alt).toBe('Gleam Programming Language Logo')
        expect(result.data.width).toBe(400)
      }
    })
  })

  describe('ContentBlock', () => {
    it('validates heading block fixture against Zod schema', () => {
      const fixture = loadFixture('content_block_heading.json')

      const result = ContentBlockSchema.safeParse(fixture)

      expect(result.success).toBe(true)
      if (result.success) {
        expect(result.data.type).toBe('heading')
        expect(result.data).toHaveProperty('text', 'Introduction to Gleam')
      }
    })

    it('validates code block fixture against Zod schema', () => {
      const fixture = loadFixture('content_block_code.json')

      const result = ContentBlockSchema.safeParse(fixture)

      expect(result.success).toBe(true)
      if (result.success) {
        expect(result.data.type).toBe('code_block')
        expect(result.data).toHaveProperty('code')
        expect(result.data).toHaveProperty('language', 'gleam')
        expect(result.data).toHaveProperty('highlight_lines')
        if ('highlight_lines' in result.data) {
          expect(result.data.highlight_lines).toEqual([2])
        }
      }
    })

    it('validates columns block fixture with recursive content against Zod schema', () => {
      const fixture = loadFixture('content_block_columns.json')

      const result = ContentBlockSchema.safeParse(fixture)

      expect(result.success).toBe(true)
      if (result.success) {
        expect(result.data.type).toBe('columns')
        expect(result.data).toHaveProperty('left')
        expect(result.data).toHaveProperty('right')

        if ('left' in result.data && 'right' in result.data) {
          // Verify left column structure
          expect(Array.isArray(result.data.left)).toBe(true)
          expect(result.data.left).toHaveLength(2)
          expect(result.data.left[0].type).toBe('heading')
          expect(result.data.left[1].type).toBe('bullet_list')

          // Verify right column structure
          expect(Array.isArray(result.data.right)).toBe(true)
          expect(result.data.right).toHaveLength(2)
          expect(result.data.right[0].type).toBe('heading')
          expect(result.data.right[1].type).toBe('paragraph')
        }
      }
    })
  })

  describe('Slide', () => {
    it('validates slide fixture against Zod schema', () => {
      const fixture = loadFixture('slide.json')

      const result = SlideSchema.safeParse(fixture)

      expect(result.success).toBe(true)
      if (result.success) {
        expect(result.data.number).toBe(1)
        expect(result.data.title).toBe('Welcome to Inertia-Wisp')
        expect(result.data.notes).toBe('Welcome slide - introduce the main topics and technologies covered in this presentation.')

        // Verify content array structure
        expect(Array.isArray(result.data.content)).toBe(true)
        expect(result.data.content).toHaveLength(7)

        // Verify content block types
        expect(result.data.content[0].type).toBe('heading')
        expect(result.data.content[1].type).toBe('subheading')
        expect(result.data.content[2].type).toBe('paragraph')
        expect(result.data.content[3].type).toBe('bullet_list')
        expect(result.data.content[4].type).toBe('code_block')
        expect(result.data.content[5].type).toBe('spacer')
        expect(result.data.content[6].type).toBe('quote')
      }
    })
  })

  describe('SlideNavigation', () => {
    it('validates slide_navigation fixture against Zod schema', () => {
      const fixture = loadFixture('slide_navigation.json')

      const result = SlideNavigationSchema.safeParse(fixture)

      expect(result.success).toBe(true)
      if (result.success) {
        expect(result.data.current).toBe(5)
        expect(result.data.total).toBe(15)
        expect(result.data.has_previous).toBe(true)
        expect(result.data.has_next).toBe(true)
        expect(result.data.previous_url).toBe('/slides/4')
        expect(result.data.next_url).toBe('/slides/6')
      }
    })
  })

  describe('Error Cases', () => {
    it('rejects invalid slide with missing required fields', () => {
      const invalidSlide = {
        number: 1,
        title: 'Missing content field',
        // content missing
        notes: 'test'
      }

      const result = SlideSchema.safeParse(invalidSlide)

      expect(result.success).toBe(false)
    })

    it('rejects invalid content block with unknown type', () => {
      const invalidBlock = {
        type: 'unknown_type',
        text: 'This should fail'
      }

      const result = ContentBlockSchema.safeParse(invalidBlock)

      expect(result.success).toBe(false)
    })

    it('rejects code block with invalid highlight_lines type', () => {
      const invalidCodeBlock = {
        type: 'code_block',
        code: 'test code',
        language: 'gleam',
        highlight_lines: 'not an array' // Should be array of numbers
      }

      const result = ContentBlockSchema.safeParse(invalidCodeBlock)

      expect(result.success).toBe(false)
    })
  })
})
