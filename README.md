# 國語小字典快查 (MiniMoeDict)

把教育部《國語小字典》(<https://dict.mini.moe.edu.tw>) 包成原生 iOS App，輸入字 / 詞馬上查。

- **平台**：iOS 16.0+（iPhone、iPad）
- **語言**：Swift 5.9 / SwiftUI
- **核心元件**：`WKWebView`，已鎖定只能瀏覽 `dict.mini.moe.edu.tw`，外部連結自動丟給 Safari
- **CI/CD**：GitHub Actions（macos-14 runner）

---

## 一、快速使用

### A. 自己 clone 編譯（不需 Apple Developer 付費帳號）

需要 macOS 13+ 與 Xcode 15.x。

```bash
# 1. clone
git clone https://github.com/changyow-ai/cht-word-info.git
cd cht-word-info

# 2. 安裝 XcodeGen（第一次）
brew install xcodegen

# 3. 產生 .xcodeproj
xcodegen generate

# 4. 用 Xcode 開啟
open MiniMoeDict.xcodeproj
```

在 Xcode 內：

1. 左側點選 `MiniMoeDict` 專案 → `Signing & Capabilities`。
2. **Team** 選你自己的 Apple ID（個人帳號就會出現「Personal Team」）。
3. 把 **Bundle Identifier** 改成獨一無二的字串（例如 `com.yourname.minimoedict`），個人帳號才不會撞名。
4. 接上實機（或選 iOS Simulator）→ ⌘R。

> 個人帳號簽出來的 App 有效期 7 天，過期重新從 Xcode 跑一次就會續簽。

### B. 用 GitHub Actions 編譯（需 Apple Developer 帳號）

1. Fork 這個 repo。
2. 在 GitHub Settings → Secrets and variables → Actions 加上下方「必要 Secrets」。
3. 推一個 tag 觸發 release：
   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```
4. 到 Actions 頁面等 workflow 跑完，下載 `MiniMoeDict-ipa` artifact，或從 Releases 頁面取得 `.ipa`。
5. 用 Apple Configurator 2 / Xcode → Window → Devices 安裝 `.ipa` 到實機。

---

## 二、GitHub Actions 簽章設定

### 必要 Secrets

| Secret 名稱 | 取得 / 說明 |
|---|---|
| `BUILD_CERTIFICATE_BASE64` | iOS Distribution / Development 憑證的 `.p12` 匯出檔，做 `base64 -i cert.p12 \| pbcopy` 後貼上 |
| `P12_PASSWORD` | 匯出 `.p12` 時設的密碼 |
| `BUILD_PROVISION_PROFILE_BASE64` | Provisioning Profile (`.mobileprovision`) 的 base64：`base64 -i profile.mobileprovision \| pbcopy` |
| `KEYCHAIN_PASSWORD` | 隨意亂數（如 `openssl rand -hex 16` 的輸出），只在 CI run 期間使用 |
| `APPLE_TEAM_ID` | 10 碼 Team ID（Apple Developer Portal → Membership） |
| `BUNDLE_ID` | Provisioning Profile 對應的 Bundle Identifier（如 `tw.example.minimoedict`） |
| `PROVISIONING_PROFILE_NAME` | Profile 內的 **Name** 欄位（不是檔名、不是 UUID） |
| `EXPORT_METHOD` | `development`、`ad-hoc` 或 `app-store`，必須與 profile 類型相符 |

> 建議第一版用 **development** 或 **ad-hoc** profile，限定特定 UDID 安裝，外洩時影響範圍小。

### 把 `.cer` 轉成 `.p12` 的步驟（只需做一次）

1. Mac 上開「鑰匙圈存取」(Keychain Access)。
2. 找到對應的 iPhone Developer / Distribution 憑證（含 ▶ 私鑰）。
3. 右鍵 → 「輸出」→ 存成 `.p12`，輸入密碼（這就是 `P12_PASSWORD`）。
4. `base64 -i cert.p12 | pbcopy` → 貼到 GitHub Secret。

### Workflow 觸發方式

| Workflow | 觸發 | 動作 |
|---|---|---|
| `.github/workflows/build.yml` | push（非 tag）/ PR | 無簽章 build + 跑單元測試 |
| `.github/workflows/release.yml` | push tag `v*` 或 workflow_dispatch | 簽章 → archive → export `.ipa` → 上傳 artifact / 草稿 Release |

---

## 三、安全性說明

- 所有憑證、Profile 一律透過 **GitHub Encrypted Secrets** 注入，不進 repo；`.gitignore` 已將 `*.p12 / *.mobileprovision / *.cer / ExportOptions.plist` 排除。
- CI 在 runner 上建立**暫時 keychain**，build 結束後（`if: always()`）一律 `security delete-keychain` 清除。Profile 也一併刪除。
- 解碼憑證時用 `printf '%s' | base64 --decode`（避免 trailing newline）並先檢查檔案非空，可早期發現 secret 設定錯誤。
- App 端在 `WKNavigationDelegate.decidePolicyFor` 與 `Info.plist` 的 `WKAppBoundDomains` 雙層鎖定，僅允許 `dict.mini.moe.edu.tw`。任何外部連結轉交 Safari，不在 App 內開啟。
- `release.yml` 的 trigger **只接受 tag push 與 workflow_dispatch**，不會被外部 PR 觸發 → secrets 不會洩漏給未信任的貢獻者。
- 若懷疑憑證或 profile 外洩，立即至 Apple Developer Portal Revoke 該憑證並重新產生 profile。

---

## 四、專案結構

```
cht-word-info/
├── README.md
├── .gitignore
├── project.yml                     # XcodeGen manifest
├── ExportOptions.template.plist    # CI 用 envsubst 渲染
├── App/
│   ├── MiniMoeDictApp.swift        # @main entry
│   ├── ContentView.swift           # SearchBar + DictWebView
│   ├── DictWebView.swift           # UIViewRepresentable + 網域鎖定
│   ├── SearchViewModel.swift       # 查詢狀態
│   ├── DictURL.swift               # 純函式：組搜尋 URL / 網域驗證
│   ├── Info.plist
│   └── Assets.xcassets/
├── Tests/
│   └── DictURLTests.swift
└── .github/workflows/
    ├── build.yml                   # 無簽章 smoke test
    └── release.yml                 # 簽章 IPA
```

---

## 五、開發 / 維護備忘

- 改完 `project.yml` 後務必執行 `xcodegen generate` 重新產出 `.xcodeproj`，再開 Xcode。
- `App/Info.plist` 內 `WKAppBoundDomains` 若日後需開放更多網域，記得同步更新 `App/DictURL.swift` 的 `allowedHost`。
- 搜尋 URL 規格：`https://dict.mini.moe.edu.tw/SearchIndex/searchResult?searchType={one|more}&dictSearchField={URL-encoded}`。
- 想自訂 App Icon：把 1024×1024 PNG 放進 `App/Assets.xcassets/AppIcon.appiconset/` 並更新 `Contents.json`。

---

## 六、版權與聲明

本專案僅是教育部《國語小字典》網站的非官方 iOS 殼，所有辭典內容與商標皆屬中華民國教育部。本 App 程式碼以 MIT 授權釋出。
