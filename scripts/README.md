# TIM SDK Scripts

这个目录包含了管理 TIM SDK 的自动化脚本。

## 脚本说明

### update_opentoy_framework.sh

用于更新 `tim_sdk` 中的 `opentoy_ios.xcframework` 依赖。

#### 使用方法

```bash
# 使用默认路径 (../opentoy_ios)
./scripts/update_opentoy_framework.sh

# 指定 opentoy_ios 的绝对路径
./scripts/update_opentoy_framework.sh /path/to/opentoy_ios

# 指定 opentoy_ios 的相对路径
./scripts/update_opentoy_framework.sh ../opentoy_ios
```

#### 前置条件

1. `opentoy_ios` 项目必须已经构建完成
2. `opentoy_ios/Build/opentoy_ios.xcframework` 必须存在

#### 构建 opentoy_ios

如果还没有构建 `opentoy_ios`，请先运行：

```bash
cd /path/to/opentoy_ios
./Scripts/build_xcframework.sh
```

#### 脚本功能

- 验证 `opentoy_ios` 项目路径
- 检查 framework 是否存在
- 删除旧的 framework
- 复制新的 framework
- 验证 framework 结构

## 工作流程

1. 在 `opentoy_ios` 中修改代码
2. 运行 `opentoy_ios` 的构建脚本
3. 运行 `tim_sdk` 的更新脚本
4. 测试 `tim_sdk` 的功能
5. 发布新版本
