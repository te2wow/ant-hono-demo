// WebSocket echo を確認するだけの最小クライアント。bun ws-client.ts で実行する。
const ws = new WebSocket("ws://localhost:8080/ws");
ws.onopen = () => ws.send("hello ant");
ws.onmessage = (e) => { console.log("received:", e.data); ws.close(); };
ws.onclose = () => process.exit(0);
setTimeout(() => { console.error("timeout"); process.exit(1); }, 3000);
