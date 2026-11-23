---
paths:
  - "**/*.{ts,tsx,mts,cts,js,jsx,mjs,cjs}"
  - "**/package.json"
---
- Use the package manager the lockfile names (`pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`). Never mix them.
- Type check with the project's own script, or `tsc --noEmit`, before calling it done.
- No `any`, `@ts-ignore`, or `as unknown as`. If a type is genuinely unknown, use `unknown` and narrow it.
- Follow the existing lint and format setup. Don't add config for tools the project doesn't use.
