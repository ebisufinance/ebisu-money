// vite.config.ts
import react from "file:///D:/Projects/eBisuFinance/ebisu-money/node_modules/.pnpm/@vitejs+plugin-react-swc@3.7.1_vite@5.4.8/node_modules/@vitejs/plugin-react-swc/index.mjs";
import { resolve } from "path";
import { defineConfig } from "file:///D:/Projects/eBisuFinance/ebisu-money/node_modules/.pnpm/vite@5.4.8_@types+node@22.7.4/node_modules/vite/dist/node/index.js";
import dts from "file:///D:/Projects/eBisuFinance/ebisu-money/node_modules/.pnpm/vite-plugin-dts@4.2.3_typescript@5.6.2_vite@5.4.8/node_modules/vite-plugin-dts/dist/index.mjs";
var __vite_injected_original_dirname = "D:\\Projects\\eBisuFinance\\ebisu-money\\frontend\\uikit";
var vite_config_default = defineConfig({
  build: {
    lib: {
      entry: {
        index: resolve(__vite_injected_original_dirname, "src/index.ts"),
        "icons/index": resolve(__vite_injected_original_dirname, "src/icons/index.ts")
      },
      formats: ["es"]
    },
    sourcemap: true,
    rollupOptions: {
      external: [
        "@pandacss/dev",
        "@react-spring/web",
        "react",
        "react-dom",
        "react/jsx-runtime",
        "ts-pattern"
      ],
      output: {
        banner: () => "'use client';",
        preserveModules: true,
        dir: "dist"
      }
    },
    emptyOutDir: false
  },
  plugins: [
    react(),
    dts()
  ]
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcudHMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCJEOlxcXFxQcm9qZWN0c1xcXFxlQmlzdUZpbmFuY2VcXFxcZWJpc3UtbW9uZXlcXFxcZnJvbnRlbmRcXFxcdWlraXRcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfZmlsZW5hbWUgPSBcIkQ6XFxcXFByb2plY3RzXFxcXGVCaXN1RmluYW5jZVxcXFxlYmlzdS1tb25leVxcXFxmcm9udGVuZFxcXFx1aWtpdFxcXFx2aXRlLmNvbmZpZy50c1wiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9pbXBvcnRfbWV0YV91cmwgPSBcImZpbGU6Ly8vRDovUHJvamVjdHMvZUJpc3VGaW5hbmNlL2ViaXN1LW1vbmV5L2Zyb250ZW5kL3Vpa2l0L3ZpdGUuY29uZmlnLnRzXCI7aW1wb3J0IHJlYWN0IGZyb20gXCJAdml0ZWpzL3BsdWdpbi1yZWFjdC1zd2NcIjtcbmltcG9ydCB7IHJlc29sdmUgfSBmcm9tIFwicGF0aFwiO1xuaW1wb3J0IHsgZGVmaW5lQ29uZmlnIH0gZnJvbSBcInZpdGVcIjtcbmltcG9ydCBkdHMgZnJvbSBcInZpdGUtcGx1Z2luLWR0c1wiO1xuXG5leHBvcnQgZGVmYXVsdCBkZWZpbmVDb25maWcoe1xuICBidWlsZDoge1xuICAgIGxpYjoge1xuICAgICAgZW50cnk6IHtcbiAgICAgICAgaW5kZXg6IHJlc29sdmUoX19kaXJuYW1lLCBcInNyYy9pbmRleC50c1wiKSxcbiAgICAgICAgXCJpY29ucy9pbmRleFwiOiByZXNvbHZlKF9fZGlybmFtZSwgXCJzcmMvaWNvbnMvaW5kZXgudHNcIiksXG4gICAgICB9LFxuICAgICAgZm9ybWF0czogW1wiZXNcIl0sXG4gICAgfSxcbiAgICBzb3VyY2VtYXA6IHRydWUsXG4gICAgcm9sbHVwT3B0aW9uczoge1xuICAgICAgZXh0ZXJuYWw6IFtcbiAgICAgICAgXCJAcGFuZGFjc3MvZGV2XCIsXG4gICAgICAgIFwiQHJlYWN0LXNwcmluZy93ZWJcIixcbiAgICAgICAgXCJyZWFjdFwiLFxuICAgICAgICBcInJlYWN0LWRvbVwiLFxuICAgICAgICBcInJlYWN0L2pzeC1ydW50aW1lXCIsXG4gICAgICAgIFwidHMtcGF0dGVyblwiLFxuICAgICAgXSxcbiAgICAgIG91dHB1dDoge1xuICAgICAgICBiYW5uZXI6ICgpID0+IFwiJ3VzZSBjbGllbnQnO1wiLFxuICAgICAgICBwcmVzZXJ2ZU1vZHVsZXM6IHRydWUsXG4gICAgICAgIGRpcjogXCJkaXN0XCIsXG4gICAgICB9LFxuICAgIH0sXG4gICAgZW1wdHlPdXREaXI6IGZhbHNlLFxuICB9LFxuICBwbHVnaW5zOiBbXG4gICAgcmVhY3QoKSxcbiAgICBkdHMoKSxcbiAgXSxcbn0pO1xuIl0sCiAgIm1hcHBpbmdzIjogIjtBQUF1VixPQUFPLFdBQVc7QUFDelcsU0FBUyxlQUFlO0FBQ3hCLFNBQVMsb0JBQW9CO0FBQzdCLE9BQU8sU0FBUztBQUhoQixJQUFNLG1DQUFtQztBQUt6QyxJQUFPLHNCQUFRLGFBQWE7QUFBQSxFQUMxQixPQUFPO0FBQUEsSUFDTCxLQUFLO0FBQUEsTUFDSCxPQUFPO0FBQUEsUUFDTCxPQUFPLFFBQVEsa0NBQVcsY0FBYztBQUFBLFFBQ3hDLGVBQWUsUUFBUSxrQ0FBVyxvQkFBb0I7QUFBQSxNQUN4RDtBQUFBLE1BQ0EsU0FBUyxDQUFDLElBQUk7QUFBQSxJQUNoQjtBQUFBLElBQ0EsV0FBVztBQUFBLElBQ1gsZUFBZTtBQUFBLE1BQ2IsVUFBVTtBQUFBLFFBQ1I7QUFBQSxRQUNBO0FBQUEsUUFDQTtBQUFBLFFBQ0E7QUFBQSxRQUNBO0FBQUEsUUFDQTtBQUFBLE1BQ0Y7QUFBQSxNQUNBLFFBQVE7QUFBQSxRQUNOLFFBQVEsTUFBTTtBQUFBLFFBQ2QsaUJBQWlCO0FBQUEsUUFDakIsS0FBSztBQUFBLE1BQ1A7QUFBQSxJQUNGO0FBQUEsSUFDQSxhQUFhO0FBQUEsRUFDZjtBQUFBLEVBQ0EsU0FBUztBQUFBLElBQ1AsTUFBTTtBQUFBLElBQ04sSUFBSTtBQUFBLEVBQ047QUFDRixDQUFDOyIsCiAgIm5hbWVzIjogW10KfQo=
