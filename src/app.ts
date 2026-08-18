import { Hono } from "hono";
import { logger } from "hono/logger";
import { upgradeWebSocket } from "@ant/hono";

// Sandbox に依存しない部分。ant compile で単一バイナリにできる。
export const app = new Hono();
app.use(logger());

app.get("/", (c) => c.text(`hello from Hono on Ant ${Ant.version}\n`));
app.get("/json", (c) =>
  c.json({ runtime: "ant", version: Ant.version, target: Ant.target }),
);

// @ant/hono は WebSocket 用のヘルパー。HTTP だけなら hono 本体で足りる。
app.get(
  "/ws",
  upgradeWebSocket(() => ({
    onMessage(event, ws) {
      ws.send(`echo: ${event.data}`);
    },
  })),
);
