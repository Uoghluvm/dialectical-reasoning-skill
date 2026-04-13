# Dialectical Reasoning Skill

一个可移植的开源 Agent Skill，用来学习和运用辩证法，不把复杂问题讲成口号，也不把矛盾分析简化成“各打五十大板”。

它专门处理这类任务：

- 学习辩证法的核心概念与分析步骤
- 用辩证法分析政策、商业、组织、技术与历史问题
- 解释像 `有计划的市场经济` 这样的复合概念为何不是静态拼贴
- 找出主要矛盾、矛盾主次方面、阶段变化和转折点

## 一键安装

### 自动探测目标工具

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/Uoghluvm/dialectical-reasoning-skill/main/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/Uoghluvm/dialectical-reasoning-skill/main/install.ps1 | iex
```

默认会自动探测并安装到这些目录之一：

- `Codex` -> `~/.codex/skills/dialectical-reasoning`
- `Claude Code` -> `~/.claude/skills/dialectical-reasoning`
- `OpenClaw / QClaw / agents` -> `~/.agents/skills/dialectical-reasoning`

### 指定安装到某个工具

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/Uoghluvm/dialectical-reasoning-skill/main/install.sh | bash -s -- --tool claude
curl -fsSL https://raw.githubusercontent.com/Uoghluvm/dialectical-reasoning-skill/main/install.sh | bash -s -- --tool codex
curl -fsSL https://raw.githubusercontent.com/Uoghluvm/dialectical-reasoning-skill/main/install.sh | bash -s -- --tool openclaw
```

Windows PowerShell:

```powershell
$env:DIALECTICAL_TOOL='claude'; irm https://raw.githubusercontent.com/Uoghluvm/dialectical-reasoning-skill/main/install.ps1 | iex
$env:DIALECTICAL_TOOL='codex'; irm https://raw.githubusercontent.com/Uoghluvm/dialectical-reasoning-skill/main/install.ps1 | iex
$env:DIALECTICAL_TOOL='openclaw'; irm https://raw.githubusercontent.com/Uoghluvm/dialectical-reasoning-skill/main/install.ps1 | iex
```

## 适合的提示词

- 用辩证法分析“有计划的市场经济”为何不是自相矛盾的词组
- 帮我找出一家创业公司在增长和利润之间的主要矛盾
- 用辩证法分析 AI 开源与闭源的关系，不要只讲立场
- 解释这个政策争论中，哪个矛盾是主要矛盾，哪个只是次要矛盾

## 仓库结构

```text
.
├── .claude-plugin/
├── install.ps1
├── install.sh
├── LICENSE
├── README.md
└── skills/
    └── dialectical-reasoning/
        ├── SKILL.md
        ├── agents/openai.yaml
        └── references/
```

## 设计原则

- 反对把辩证法做成空话生成器
- 强调阶段、条件、主次矛盾与转化机制
- 允许张力存在，不强行输出“折中”结论
- 区分事实、推断与价值判断

## 许可

MIT
