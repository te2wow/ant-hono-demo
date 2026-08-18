# 2. 単一バイナリにして node_modules 無しで動かす
Output recordings/02-compile.gif
Source tapes/_common.tape

Type "ant compile -o dist/server src/server.ts"
Enter
Sleep 5s

Type "ls -lh dist/server"
Enter
Sleep 2s

Type "clear"
Enter

Type "cp dist/server /tmp/standalone/ && cd /tmp/standalone && ls -la"
Enter
Sleep 2.5s

Type "./server &"
Enter
Sleep 2s

Type "curl -s -w '\n' localhost:8080/json"
Enter
Sleep 2s

Type "bun ~/src/github.com/te2wow/ant-hono-demo/ws-client.ts"
Enter
Sleep 3s

Type "kill %1"
Enter
Sleep 1.5s
