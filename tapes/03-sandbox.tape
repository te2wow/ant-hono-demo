# 3. Sandbox: POST したコードを VM で隔離実行する
Output recordings/03-sandbox.gif
Source tapes/_common.tape

Type "ant src/index.ts &"
Enter
Sleep 2s

Type `curl -s -w '\n' -X POST localhost:8080/run -d '{"code":"return [1,2,3].map(n => n * 2)"}'`
Enter
Sleep 3s

Type `curl -s -w '\n' -X POST localhost:8080/run -d '{"code":"while (true) {}"}'`
Enter
Sleep 3s

Type `curl -s -w '\n' -X POST localhost:8080/run -d '{"code":"const fs = await import(\"ant:fs\"); return fs.readFile(\"/etc/hosts\").catch(e => e.message)"}'`
Enter
Sleep 4s

Type "kill %1"
Enter
Sleep 1.5s
