# ant-hono-demo

[Ant](https://antjs.org)（[theMackabu/ant](https://github.com/theMackabu/ant)）の上で [Hono](https://hono.dev) を動かすデモです。

- 素の `hono` パッケージがそのまま動くこと
- `ant compile` で Hono ごと 1 つの実行ファイルになること
- `ant:sandbox` を使って、POST されたコードを Hypervisor 上の VM で隔離実行すること

を確かめる構成になっています。Ant `14.0` / Hono `4.13.2` / `@ant/hono` `0.0.4` で確認しました。

## 構成

| ファイル | 役割 |
| --- | --- |
| `src/app.ts` | Hono アプリ本体。`/`, `/json`, `/ws`（WebSocket echo） |
| `src/server.ts` | `app` をそのまま起動するエントリ。`ant compile` の対象 |
| `src/index.ts` | `app` に `POST /run` を足したエントリ。`ant:sandbox` を使うので `ant` コマンドで起動する |
| `bench-coldstart.js` | README のコールドスタート計測と同じ形のスクリプト |

## 動かす

```bash
curl -fsSL https://antjs.org/install | bash   # ~/.ant/bin/ant が入る
ant install
ant src/index.ts                               # http://localhost:8080
```

```bash
curl localhost:8080/
curl localhost:8080/json
curl -X POST localhost:8080/run -H 'content-type: application/json' \
  -d '{"code":"return [1,2,3].map(n => n * 2)"}'
curl -X POST localhost:8080/run -H 'content-type: application/json' \
  -d '{"code":"while (true) {}"}'               # SandboxCpuTimeLimit で 400
```

## 単一バイナリにする

```bash
ant run compile        # dist/server ができる
./dist/server          # node_modules が無いディレクトリでも動く
```

`ant:sandbox` を import しているエントリ（`src/index.ts`）は、この記事執筆時点の `ant compile` では
`Cannot resolve module: ant:sandbox` になるため、コンパイル対象は `src/server.ts` にしています。

## コールドスタート

```bash
ant run bench          # hyperfine が必要
```

## 触っていて分かったこと

- `Sandbox` の `memory` は API 上 64mb から受け付けるが、この環境で安定して起動したのは 112mb 以上だった（64mb・80mb は SandboxTimeout）。既定値（256MiB）に任せるのが無難
- `Sandbox#eval` に Promise を返すと await されずに inspect 文字列が返る。`export default await ...` の形にする
- CPU 制限に達した `Sandbox` は `close()` も同じエラーで reject する。後始末は `terminate()` を使う
- `export default { fetch: app.fetch }` と書くと、`.ts` ファイルに限って `app` が未定義になる。`(req, ctx) => app.fetch(req, ctx)` と関数式で包むと動く
- `ant compile -o dist/server` は出力先ディレクトリを作らない。先に `mkdir` が要る
