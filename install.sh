#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-Uoghluvm}"
REPO_NAME="${REPO_NAME:-dialectical-reasoning-skill}"
REPO_REF="${REPO_REF:-main}"
SKILL_NAME="dialectical-reasoning"
TOOL="${DIALECTICAL_TOOL:-auto}"
DESTINATION="${DIALECTICAL_DESTINATION:-}"

usage() {
  cat <<'EOF'
Usage: install.sh [--tool auto|codex|claude|openclaw|all] [--destination DIR] [--ref REF]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)
      TOOL="$2"
      shift 2
      ;;
    --destination|--dest)
      DESTINATION="$2"
      shift 2
      ;;
    --ref)
      REPO_REF="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

unique_lines() {
  awk '!seen[$0]++'
}

resolve_targets() {
  if [[ -n "$DESTINATION" ]]; then
    printf '%s\n' "$DESTINATION"
    return 0
  fi

  case "$TOOL" in
    codex)
      printf '%s\n' "$HOME/.codex/skills"
      ;;
    claude|claude-code)
      printf '%s\n' "$HOME/.claude/skills"
      ;;
    openclaw|qclaw|agents)
      printf '%s\n' "$HOME/.agents/skills"
      ;;
    all)
      printf '%s\n' "$HOME/.codex/skills" "$HOME/.claude/skills" "$HOME/.agents/skills"
      ;;
    auto)
      local targets=()
      [[ -d "$HOME/.codex" || -d "$HOME/.codex/skills" ]] && targets+=("$HOME/.codex/skills")
      [[ -d "$HOME/.claude" || -d "$HOME/.claude/skills" ]] && targets+=("$HOME/.claude/skills")
      if [[ -d "$HOME/.agents" || -d "$HOME/.openclaw" || -d "$HOME/.openclaw-autoclaw" || -d "$HOME/.qclaw" ]]; then
        targets+=("$HOME/.agents/skills")
      fi

      if [[ ${#targets[@]} -eq 0 ]]; then
        targets=("$HOME/.codex/skills" "$HOME/.claude/skills" "$HOME/.agents/skills")
      fi

      printf '%s\n' "${targets[@]}" | unique_lines
      ;;
    *)
      echo "Unsupported tool: $TOOL" >&2
      exit 1
      ;;
  esac
}

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SOURCE_DIR="${SCRIPT_DIR}/skills/${SKILL_NAME}"

if [[ -d "$LOCAL_SOURCE_DIR" ]]; then
  SOURCE_DIR="$LOCAL_SOURCE_DIR"
else
  ARCHIVE_URL="https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/refs/heads/${REPO_REF}"
  ARCHIVE_PATH="$TMP_DIR/repo.tar.gz"

  echo "Downloading ${REPO_OWNER}/${REPO_NAME}@${REPO_REF} ..."
  curl -fsSL "$ARCHIVE_URL" -o "$ARCHIVE_PATH"
  tar -xzf "$ARCHIVE_PATH" -C "$TMP_DIR"

  SOURCE_DIR="$(find "$TMP_DIR" -type d -path "*/skills/${SKILL_NAME}" | head -n 1)"
  if [[ -z "$SOURCE_DIR" ]]; then
    echo "Failed to locate skills/${SKILL_NAME} in downloaded archive." >&2
    exit 1
  fi
fi

while IFS= read -r target_root; do
  [[ -z "$target_root" ]] && continue
  mkdir -p "$target_root"
  target_dir="${target_root%/}/${SKILL_NAME}"
  rm -rf "$target_dir"
  cp -R "$SOURCE_DIR" "$target_dir"
  echo "Installed to $target_dir"
done < <(resolve_targets)

echo "Done."
