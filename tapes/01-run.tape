# 1. Hono を Ant で動かす
Output recordings/01-run.gif
Source tapes/_common.tape

Type "ant --version"
Enter
Sleep 3s

Type "clear"
Enter

Type "ant src/server.ts &"
Enter
Sleep 2s

Type "curl -s -w '\n' localhost:8080/"
Enter
Sleep 2s

Type "curl -s -w '\n' localhost:8080/json"
Enter
Sleep 2s

Type "bun ws-client.ts"
Enter
Sleep 3s

Type "kill %1"
Enter
Sleep 1.5s
