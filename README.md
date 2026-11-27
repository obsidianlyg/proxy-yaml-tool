# Proxy YAML Tool

一个用 Go 编写的节点转换工具，通过 HTML 网页将分享链接或节点 YAML 转换为 Mihomo / Clash Meta 配置或 v2rayN 分享订阅。

网页资源嵌入可执行文件，运行编译好的程序无需安装 Go、Ruby、Python、Node.js 或前端依赖。

项目地址：https://github.com/obsidianlyg/proxy-yaml-tool

下载发布版本：https://github.com/obsidianlyg/proxy-yaml-tool/releases/latest

## 功能介绍

| 功能 | 说明 |
| --- | --- |
| 批量导入分享链接 | 每行一条，可粘贴或上传 TXT 文件；忽略空行和以 `#` 开头的注释 |
| 导入节点 YAML | 接受节点数组或包含 `proxies` 的 YAML 对象，也可上传 YAML 文件 |
| 合并模板 | 保留模板中的 DNS、规则和代理组，追加新节点；原模板文件不会被网页覆盖 |
| 自动去重 | 忽略名称，比较协议、服务器、端口、认证和嵌套的传输 / TLS 参数；结构化配置相同则跳过 |
| 清理已有重复项 | 默认整理模板内部的重复节点，并同步代理组、规则等引用 |
| 同步代理组 | 默认把新节点加入已有且包含 `proxies` 列表的代理组 |
| 单独修改名称 | 在结果列表编辑名称，点击“保存名称”，同步更新代理组、规则、子规则、`proxy` / `dialer-proxy` 等引用 |
| 删除节点 | 结果列表逐个删除，立即更新 YAML 和订阅，清理代理组及直接指向该节点的规则；可撤销上一次删除 |
| 国家 / 地区标记 | 可选功能，通过公网 IP 查询归属地，并为节点名称添加标记 |
| 批量替换 IP | 将本批节点复制到指定 IP，保留原端口、认证和传输配置 |
| 订阅地址 | 将完整 YAML 通过一个 HTTP 地址提供给 Clash Verge，可选启用远程访问 |
| 复制和下载 | 支持预览、复制或下载完整 YAML |
| 命令行转换 | 不启动网页，直接从模板和分享链接文件生成配置 |
| Linux BBR | 提供独立命令行入口，在运行该命令的 Linux 主机上启用 BBR |
| v2rayN 独立菜单 | 单独的 v2rayN 页面，生成 Base64 分享链接订阅，不修改 Clash Verge 订阅 |
| v2rayN 节点管理 | 可逐个改名、删除、复制分享链接，并在本地生成单节点二维码 |

### 支持的协议与传输

| 协议 | 支持范围 |
| --- | --- |
| VLESS | TCP、REALITY / TLS、WS、H2、HTTPUpgrade、gRPC |
| VMess | TCP、TLS、WS、H2、HTTPUpgrade、gRPC |
| Trojan | TLS，以及链接中的 WS、H2、HTTPUpgrade、gRPC 参数转换 |
| Hysteria2 / HY2 | UDP / QUIC，支持密码、SNI、ALPN、Salamander 混淆等参数 |
| TUIC | UDP / QUIC，支持 UUID、密码、拥塞控制等参数 |
| AnyTLS | 密码、TLS、SNI 等参数 |
| Shadowsocks | 包含 Shadowsocks 2022，保留加密方法和认证信息 |

最终能否连接还取决于客户端内核版本和服务器配置。工具负责转换配置，不会安装节点服务或修改远程服务器。

VMess 的旧版 QUIC 传输不受 Mihomo 支持，与 TUIC / Hysteria2 的 QUIC 不通用。混合导入时会显示行号和原因，跳过该节点后继续导入其他有效链接；整批均不兼容时返回错误，并保留上一份订阅。复制内容中的 `vmess\://` 转义前缀也可识别。

v2rayN 页面会保留原始分享链接中的协议、TLS、Reality、SNI、ALPN、WS、H2、HTTPUpgrade、gRPC、QUIC 等参数。导入 YAML 时，工具只在能够无损表达为分享链接时转换；无法表达的字段会在结果提示中说明，整批没有可转换节点时不会覆盖上一份 v2rayN 订阅。

## 文件说明

```text
proxy-yaml-web       编译后的程序
README.md           使用说明
template.yaml       清空节点后的完整模板，保留原 DNS、代理组和规则
run.sh              Linux / macOS 启动脚本
run.command         macOS 启动脚本（源码目录）
static/             HTML / CSS / JavaScript 源文件（源码目录）
*.go                Go 源文件（源码目录）
go.mod / go.sum     Go 依赖声明（源码目录）
Dockerfile          Docker 多阶段构建文件（镜像内置默认 template.yaml）
docker-compose.yml  Docker Compose 编排配置
.dockerignore       Docker 构建忽略清单
```

当前目录的 `template.yaml` 从外层模板复制，已清空 `proxies` 及代理组中的旧节点引用。自动选择、故障转移组暂时为空；导入节点时保留“将新节点加入已有代理组”选项，会自动填充它们。请先导入节点再将结果用于 Clash Verge。

程序默认从**运行时所在目录**读取 `./template.yaml`。`run.sh` 和 `run.command` 会先切换到脚本目录，适合直接启动。

## 使用编译好的 macOS 版本

Apple Silicon（M 系列芯片）选择 `proxy-yaml-web-macos-arm64.tar.gz`，Intel Mac 选择 `proxy-yaml-web-macos-amd64.tar.gz`。解压后双击 `run.command`，或进入解压目录执行 `./run.sh`。

发布包未做 Apple 签名或公证。若系统阻止启动，请在确认下载来源后按 macOS 的正常授权流程处理。

## 使用编译好的 Linux 版本

先在 Linux 上查看架构：

```sh
uname -m
```

| 输出 | 选择的安装包 |
| --- | --- |
| `x86_64` | `proxy-yaml-web-linux-amd64.tar.gz` |
| `aarch64` / `arm64` | `proxy-yaml-web-linux-arm64.tar.gz` |

以 amd64 为例：

```sh
tar -xzf proxy-yaml-web-linux-amd64.tar.gz
cd proxy-yaml-web-linux-amd64
./run.sh
```

arm64 使用对应包名和目录名。安装包附带已清空节点的完整模板。

程序启动后打开：

```text
http://127.0.0.1:8732
```

终端按 `Ctrl+C` 停止。程序默认在前台运行，不会自动设置开机启动。

## 使用 Docker / Docker Compose 运行

镜像使用多阶段构建，基于 Alpine 打包静态编译二进制、CA 证书（用于国家 / 地区查询）以及默认的 `template.yaml`，以非 root 用户运行。

### 使用 Docker Compose

在项目根目录执行：

```sh
docker compose up -d --build
```

默认仅绑定宿主机回环地址，打开 `http://127.0.0.1:8732` 即可使用。

如需更换端口或允许远程访问，可通过环境变量指定监听地址和端口：

```sh
LISTEN_HOST=0.0.0.0 LISTEN_PORT=8732 docker compose up -d --build
```

远程访问时页面和订阅同样无需登录，请注意配置服务器防火墙或云安全组。

如需使用自定义模板，可在 `docker-compose.yml` 中取消 `volumes` 注释并挂载自己的模板文件：

```yaml
volumes:
  - /path/to/your/template.yaml:/app/template.yaml:ro
```

停止并移除容器：

```sh
docker compose down
```

### 直接使用 Docker

构建并运行镜像：

```sh
docker build -t proxy-yaml-tool .
docker run -d --name proxy-yaml-tool -p 127.0.0.1:8732:8732 proxy-yaml-tool
```

使用自定义模板运行：

```sh
docker run -d --name proxy-yaml-tool \
  -p 127.0.0.1:8732:8732 \
  -v /path/to/your/template.yaml:/app/template.yaml:ro \
  proxy-yaml-tool
```

## 从源码编译

### 环境要求

- Go 1.24 或更新版本。
- 首次下载 Go 模块需要网络；依赖已缓存后可离线构建。
- 构建时使用 `CGO_ENABLED=0`，无需 C 编译器。

以下命令都在包含 `go.mod` 的 `go-web` 目录执行。

### 编译当前系统版本

```sh
go mod download
CGO_ENABLED=0 go build -trimpath -ldflags='-s -w' -o proxy-yaml-web .
```

### 交叉编译 Linux amd64

在 macOS 或 Linux 的 shell 中执行：

```sh
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  go build -trimpath -ldflags='-s -w' -o dist/linux-amd64/proxy-yaml-web .
```

### 交叉编译 Linux arm64

```sh
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 \
  go build -trimpath -ldflags='-s -w' -o dist/linux-arm64/proxy-yaml-web .
```

将对应二进制与模板、启动脚本一起传到目标 Linux 主机：

```sh
cp template.yaml run.sh README.md dist/linux-amd64/
cp template.yaml run.sh README.md dist/linux-arm64/
```

交叉编译出的 Linux 二进制需要在 Linux 上运行。修改 HTML、CSS 或 JavaScript 后也要重新编译，因为页面资源包含在二进制中。

## 启动方法

### 使用启动脚本

```sh
chmod +x run.sh
./run.sh
```

macOS 也可以双击 `run.command`，或在终端执行：

```sh
./run.command
```

`run.command` 在可执行文件不存在时尝试构建；源码修改后应先重新运行编译命令。

### 直接运行

先进入放有程序和模板的目录：

```sh
./proxy-yaml-web
```

指定其他模板或端口：

```sh
./proxy-yaml-web -listen 127.0.0.1:18080 -template /path/to/template.yaml
```

用脚本更换端口也可以：

```sh
./run.sh -listen 127.0.0.1:18080
```

更换端口后，使用终端显示的新地址打开网页。

### 在远程 Linux 服务器上访问网页

默认仅监听回环地址。需要直接通过服务器 IP 访问时，在服务器上运行：

```sh
./run.sh -listen 0.0.0.0:8732
```

或直接运行：

```sh
./proxy-yaml-web -listen 0.0.0.0:8732 -template ./template.yaml
```

随后在其他设备访问：

```text
网页：http://服务器IP:8732
订阅：http://服务器IP:8732/subscription.yaml
```

`0.0.0.0` 是监听地址，浏览器和 Clash Verge 应使用服务器实际 IP 或域名。需要允许服务器防火墙及云安全组的 **TCP 8732** 入站访问；工具不会自动修改防火墙。也可以指定某个网卡 IP，或使用 `-listen '[::]:8732'` 监听 IPv6。

远程模式允许任意可连接到该端口的来源 IP，无登录限制；这些访问者可以使用页面修改订阅，并读取 YAML 内的节点认证信息。跨站浏览器请求和 API 会话校验仍然保留，它们不是登录认证。

如希望继续使用默认的回环监听方式，也可以使用端口转发：

1. 在 Linux 服务器上启动 `./run.sh`。
2. 在自己的电脑打开另一个终端，建立端口转发：

   ```sh
   ssh -N -L 18732:127.0.0.1:8732 用户名@服务器地址
   ```

3. 保持两个进程运行，在自己电脑的浏览器打开 `http://127.0.0.1:18732`。
4. 转换后，页面会给出 `http://127.0.0.1:18732/subscription.yaml`，交给同一电脑上的 Clash Verge 使用。

这里的 SSH 仅用于访问网页的端口转发，工具本身不会通过 SSH 读取节点或执行远程命令。

## 网页使用流程

1. 选择“分享链接”或“节点 YAML”，粘贴内容，也可上传文件。每次转换使用当前选中的导入方式。
2. 加载当前目录模板、上传自己的模板，或使用内置的简化空白模板。
3. 按需选择清理重复节点、同步代理组和国家标记。
4. 点击“转换并生成订阅”，检查节点列表和警告。
5. 如需改名，直接编辑结果列表里的名称，再点击“保存名称”。空名称、重名、与代理组重名的名称会被拒绝；逗号、换行、制表符也不允许。
6. 复制订阅地址，在 Clash Verge 的订阅页面添加 URL 订阅；也可下载 YAML 后作为本地配置导入。

本机默认订阅地址：

```text
http://127.0.0.1:8732/subscription.yaml
```

同一地址始终返回最近一次成功转换、保存名称或删除节点后的完整结果。后续继续导入时，页面会合并到“当前配置”，保留已保存的名称和节点；点击重新加载模板会以该模板重新开始。

点击结果列表中的“删除”可立即删除节点，无需再次转换。代理组中的引用会同步清理；直接以该节点为目标的规则和子规则会移除。若其他节点或 provider 通过 `proxy` / `dialer-proxy` 依赖它，删除会被拒绝，需先处理依赖。

删除成功后，本批分享链接或节点 YAML 输入及替换 IP 会清空，防止再次转换时重新加入刚删除的节点；其他节点尚未保存的名称修改会保留。点击“撤销删除”恢复上一次删除及该批输入。继续编辑输入、修改名称、成功保存名称或生成新结果后，撤销记录会清除。此操作不修改磁盘上的模板；Clash Verge 需刷新订阅才能取得最新结果。

### v2rayN 订阅与二维码

点击左侧“v2rayN 订阅”或页面顶部的 v2rayN 菜单进入独立转换页面。这里可以粘贴每行一个分享链接、整份 Base64 订阅，或导入包含 `proxies` 的 YAML。结果使用单独的 `v2ray-subscription.txt` 地址，返回 Base64 编码的分享链接列表，不会覆盖 Clash Verge 的 `subscription.yaml`。

结果列表中的名称、删除、复制链接和二维码操作只作用于 v2rayN 列表。名称保存后会同步分享链接、订阅和二维码；删除支持撤销上一次操作。二维码由 Go 程序在本机生成 PNG，扫码后可直接导入该节点。二维码包含 UUID、密码、Reality 公钥等认证信息，请只展示给可信设备。

v2rayN 页面地址：

```text
http://127.0.0.1:8732/v2ray.html
```

v2rayN 订阅地址会在转换完成后显示，例如：

```text
http://127.0.0.1:8732/v2ray-subscription.txt
```

在 v2rayN 中把该地址添加到订阅分组后更新订阅。二维码适合单节点导入；批量节点建议使用订阅地址。

**保存范围：**订阅结果保存在服务进程内存中，不会自动写回 `template.yaml`。程序退出或服务器重启后，需要重新导入。浏览器刷新也不会自动恢复上次编辑状态；建议下载生成的 YAML 留存，下一次作为模板加载。

### 国家 / 地区标记

默认关闭。开启后，通过 HTTPS 向 `ipwho.is` 发送节点的公网 IP 查询归属地，不会发送 UUID、密码或完整分享链接。域名、内网 IP、保留地址不查询，失败时保留原名称。Linux 系统需要可用的 CA 证书和外网连接。

### 将一批节点复制到其他 IP

展开对应选项，每行输入一个 IPv4 或 IPv6。工具按输入 IP 复制本批节点，只替换服务器地址，端口、密码、UUID、SNI 等沿用原值。目标服务器必须已经具有对应配置。

## 命令行转换

准备好当前目录的 `template.yaml` 和每行一条分享链接的 `links.txt`，执行：

```sh
./proxy-yaml-web convert \
  -template ./template.yaml \
  -links ./links.txt \
  -output ./mihomo-config.yaml \
  -dedup=true
```

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `-template` | `./template.yaml` | 输入模板路径 |
| `-links` | 空 | 分享链接文本文件；省略时只整理模板 |
| `-output` | 空 | 输出文件；省略时写入标准输出 |
| `-dedup` | `true` | 清理模板内部重复节点 |
| `-country` | `false` | 查询公网 IP 的国家 / 地区 |

CLI 会同步代理组。已有输出文件会先创建 `.bak` 备份，重复备份使用编号。CLI 转换结果不会自动发布到网页订阅。

## Linux BBR

在需要启用 BBR 的 Linux 主机执行，先查看拟使用的设置：

```sh
./proxy-yaml-web bbr --dry-run
```

确认后执行：

```sh
./proxy-yaml-web bbr
```

命令会将 `fq` 队列和 `bbr` 拥塞控制设置写入 `/etc/sysctl.d/99-proxy-yaml-tool-bbr.conf`，随后执行 `sysctl --system`。需要 root 权限，非 root 用户会调用 `sudo`；能否启用取决于 Linux 内核支持情况。网页不会执行这条命令。

## 常见问题

### 提示找不到模板

在包含 `template.yaml` 的目录运行，使用启动脚本，或通过 `-template` 指定绝对路径。网页找不到模板时会使用内置空白模板，CLI 则返回文件错误。

### 提示端口被占用

先停止占用端口的旧进程，或改用其他回环端口，例如 `./run.sh -listen 127.0.0.1:18080`。

### Linux 提示无法执行或 Exec format error

用 `uname -m` 确认架构与安装包一致。检查是否误用了 macOS 二进制；没有执行权限时运行 `chmod +x proxy-yaml-web run.sh`。

### Clash Verge 无法更新订阅

确认转换已成功、Go 程序仍在运行，且 Clash Verge 能访问网页显示的订阅地址。直接远程访问时检查监听地址、防火墙和云安全组；使用 SSH 转发时保持转发进程运行。没有生成结果时，订阅接口返回 404。

### 名称改了，订阅里仍是旧名称

点击“保存名称”，看到保存成功提示后，再刷新 Clash Verge 订阅。名称尚未保存时，页面会暂时禁用复制和下载。

### 大批量或格式错误

一次转换最多处理 1000 个节点（包括模板已有节点和去重前的待导入节点）。HTTP 请求体上限为 4 MiB；网页的 TXT 上传上限为 1 MiB，YAML 上传上限为 3 MiB。除明确提示可跳过的不兼容传输外，链接格式错误会中止本次转换，以免无声遗漏节点。

## 开发验证

```sh
gofmt -w *.go
go test -race ./...
go vet ./...
go build -trimpath -o proxy-yaml-web .
node --check static/app.js
```

`go test -race` 需要当前系统具备 Go race 检测所需的 C 编译环境；构建静态发布二进制不需要。测试包含本机回环 HTTP 监听，不会连接真实节点。Node.js 只用于 JavaScript 语法检查，运行工具不需要它。
