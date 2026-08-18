import { app } from "./app";

// ant compile -o dist/server src/server.ts で単一バイナリになるエントリ。
//
// Ant は fetch の第 2 引数にサーバコンテキストを渡し、Hono がそれを c.env に載せる。
// @ant/hono の upgradeWebSocket はそこを見るので、第 2 引数まで転送する。
// (`fetch: app.fetch` と書くと、v14 では TypeScript ファイルに限って import 束縛が
//  解決されず ReferenceError になるため、関数式で包んでいる)
export default {
  port: 8080,
  fetch: (req: Request, ctx: unknown) => app.fetch(req, ctx),
};
