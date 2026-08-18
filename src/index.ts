import { Sandbox } from "ant:sandbox";
import { app } from "./app";

// POST されたコードを、Hypervisor.framework 上の VM で隔離実行する。
// ant:sandbox は ant compile の単一バイナリでは解決できないので、
// このエントリは `ant src/index.ts` で起動する前提。
app.post("/run", async (c) => {
  const { code } = await c.req.json<{ code: string }>();
  const sandbox = new Sandbox({
    mount: ".:/workspace",
    cpuTimeMs: 200,
  });
  try {
    // ゲスト側で await まで済ませてから返す (Promise のまま返すと inspect 文字列になる)
    const result = await sandbox.eval(
      `export default await (async () => { ${code} })()`,
    );
    return c.json({ ok: true, result, stats: sandbox.stats() });
  } catch (e) {
    const err = e instanceof Error ? e : new Error(String(e));
    return c.json({ ok: false, error: err.name, message: err.message }, 400);
  } finally {
    await sandbox.terminate().catch(() => {});
  }
});

export default {
  port: 8080,
  fetch: (req: Request, ctx: unknown) => app.fetch(req, ctx),
};
