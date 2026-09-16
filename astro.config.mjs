// @ts-check
import { defineConfig } from 'astro/config';
import { rehypeToc } from './src/lib/rehype-toc.mjs';

// https://astro.build/config
export default defineConfig({
  markdown: {
    rehypePlugins: [rehypeToc],
  },
});
