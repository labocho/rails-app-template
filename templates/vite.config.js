/** @type {import('vite').UserConfig} */

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  build: {
    assetsDir: "packs",
    emptyOutDir: false,
    // manifest.json を出力
    manifest: true,
    // ビルド出力を public/packs 下に
    outDir: "public",
    rollupOptions: {
      input: [
        // app/javascript/packs 下にあるファイルを指定
        "app/javascript/packs/application.js",
        "app/javascript/images/index.js",
      ]
    }
  },
  plugins: [vue()],
  resolve: {
    alias: {
      // import "~/path/to/file" が import `${__dirname}/app/javascript/path/to/file` に解釈されるようにする
      '~/': `${__dirname}/app/javascript/`,
    }
  }
})
