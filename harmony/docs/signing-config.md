# 鸿蒙签名配置指南

> 最后更新：2026-06-22

## 一、签名基础概念

| 概念       | 文件    | 用途                            |
| ---------- | ------- | ------------------------------- |
| 密钥库     | `.p12`  | 包含私钥 + 证书，由开发者保管   |
| CSR        | `.csr`  | 证书签名请求，上传给华为        |
| 证书       | `.p7b`  | 华为返回的发布证书              |
| Profile    | `.p7b`  | 描述"哪个 bundleName + 哪份证书 + 哪些设备"的元数据 |

> ⚠️ **p12 永远不能上传到任何公开地方（包括 git）**。华为 AGC 也只需要 CSR（不含私钥）。

## 二、生成密钥库 + CSR（本地一次性操作）

### 步骤

1. **DevEco Studio → Build → Generate Key and CSR**

2. **Key Store** 配置：
   ```
   Key store file:    harmony/release.p12
   Password:          ************  (建议 16+ 位，记住！)
   Confirm password:  ************
   ```

3. **Key** 配置：
   ```
   Alias:             fnc
   Password:          ************  (可与 store 不同)
   Validity:          25
   First and last name:  Piao
   Organizational unit:  （留空）
   Organization:      Piao
   City:              Beijing
   State:             Beijing
   Country code:      CN
   ```

4. **CSR** 配置：
   ```
   File name:         harmony/release.csr
   Profile:           （留空，下面在 AGC 创建）
   ```

5. 点 **OK** → 生成两个文件

### 验证

```bash
ls -la harmony/release.p12 harmony/release.csr
# -rw-------  1 user  staff  2524 Jun 22 10:00 release.p12
# -rw-------  1 user  staff  1024 Jun 22 10:00 release.csr
```

⚠️ `.p12` 备份到至少 2 个不同位置（U 盘 + 云盘）。丢了无法找回。

## 三、在 AGC 创建 Profile

1. AGC → 我的项目 → HarmonyOS 应用 → 选你的应用
2. **"构建" → "证书管理"** → **"新增证书"**
   - 证书类型：发布证书
   - 上传 CSR：选刚生成的 `harmony/release.csr`
   - 证书名称：fnc_release
3. **"Profile 管理"** → **"新增 Profile"**
   - Profile 类型：发布
   - Profile 名称：fnc_profile
   - 证书：选刚才创建的
   - 权限：默认
   - 设备：手机 + 平板
4. 点 **"下载"** → 保存为 `harmony/release.p7b`

## 四、配置项目签名

修改 `harmony/build-profile.json5`：

```json5
{
  "app": {
    "signingConfigs": [
      {
        "name": "release",
        "type": "HarmonyOS",
        "material": {
          "certpath": "release.p12",
          "keyAlias": "fnc",
          "keyAliasPassword": "你的key密码",
          "storePassword": "你的store密码",
          "profile": "release.p7b",
          "signAlg": "SHA256withECDSA"
        }
      }
    ],
    "products": [
      {
        "name": "default",
        "signingConfig": "release",   // ← 改这里
        "compatibleSdkVersion": "5.0.0(12)",
        "targetSdkVersion": "5.0.0(12)",
        "runtimeOS": "HarmonyOS",
        ...
      }
    ]
  }
}
```

> ⚠️ `keyAliasPassword` 和 `storePassword` 会明文写在 json5 文件中。
> 如果不想明文，可以用环境变量：
> ```json5
> "keyAliasPassword": "${KEY_ALIAS_PASSWORD}",
> "storePassword": "${STORE_PASSWORD}"
> ```
> 然后在执行 build 前 `export KEY_ALIAS_PASSWORD=...`

## 五、编译 Release HAP

```
DevEco Studio → Build → Build Hap(s) / APP(s) → Build Hap(s)
```

产物路径：
```
harmony/entry/build/default/outputs/default/entry-default-signed.hap
```

## 六、签名验证

```bash
# 解压 HAP 验证签名
unzip -l harmony/entry/build/default/outputs/default/entry-default-signed.hap | grep -E "p7b|signature"
# 应该看到 META-INF/CERT.SF, META-INF/CERT.RSA, META-INF/*SF 等
```

## 七、常见问题

| 问题 | 解决 |
| --- | --- |
| 编译报"profile not found" | 检查 `signingConfigs` 的 `profile` 路径是否正确 |
| 编译报"alias not match" | 检查 `keyAlias` 是否和 p12 里的别名一致 |
| 编译报"password wrong" | 重新输入 `keyAliasPassword` 和 `storePassword` |
| 上传 AGC 报"签名不匹配" | 检查 Profile 里的 bundleName 是否和 `app.json5` 一致 |

## 八、安全建议

- [ ] `harmony/release.p12` 和 `release.p7b` 加入 `.gitignore`（**已经**）
- [ ] 1Password / Keychain 存储密码
- [ ] 至少 2 份异地备份
- [ ] 团队成员权限管理（如果将来有团队）
- [ ] 定期轮换签名证书（鸿蒙不强制，但 5-10 年是良好实践）

---

**Designed by Piao with opencode**
