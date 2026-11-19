#!/usr/bin/env bash
#
# upload-image.sh — Upload ảnh mới lên repo nqdev-storage/s3-001 và trả raw URL để chèn vào book.
#
# Ví dụ:
#   scripts/upload-image.sh ./screenshot.png --article cong-nghe/devsecops/docker/README.md
#   scripts/upload-image.sh a.png b.png --article cong-nghe/foo/bar.md --width 563
#   scripts/upload-image.sh ./img.png --book cong-nghe --subdir infra/acme --slug acme-serial3
#
# Biến môi trường:
#   S3_001_DIR   — thư mục clone local của s3-001 (mặc định: ~/.cache/nqdev-s3-001)
#   S3_001_TOKEN — PAT có quyền push vào nqdev-storage/s3-001 (tuỳ chọn, fallback gh auth/git credential)
#   S3_001_REPO  — owner/repo (mặc định: nqdev-storage/s3-001)
#
set -euo pipefail

S3_REPO="${S3_001_REPO:-nqdev-storage/s3-001}"
S3_DIR="${S3_001_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/nqdev-s3-001}"
TOKEN="${S3_001_TOKEN:-${GITHUB_TOKEN:-}}"

# ---------- defaults ----------
ARTICLE=""
BOOK=""
SUBDIR=""
SLUG=""
NAME=""
ALT=""
WIDTH=""
CAPTION=""
INSERT=0
MARKER=""
DRY_RUN=0
FORCE=0
FRESH=0

IMAGES=()

usage() {
  cat <<'EOF'
Usage: upload-image.sh [options] <image-file>...

Options:
  --article PATH     Đường dẫn file markdown bài viết (để suy ra book/subdir/slug).
  --book NAME        Ghi đè book (vd: cong-nghe).
  --subdir PATH      Ghi đè thư mục con trong gitbook/blogs/<book>/ (vd: infra/acme).
  --slug NAME        Ghi đè slug cơ sở (mặc định lấy từ tên file bài).
  --name NAME        Tên file đích tường minh (không kèm đuôi); bỏ qua đánh số tự động.
  --alt TEXT         alt text cho snippet <img>.
  --width N          width attribute (vd: 563).
  --caption TEXT     figcaption.
  --insert           Chèn snippet vào file bài (--article). Mặc định append cuối file.
  --marker TEXT      Chèn snippet sau dòng chứa TEXT (dùng với --insert).
  --dry-run          Chỉ in kế hoạch, không clone/push/verify.
  --fresh            Xoá clone local và clone lại.
  --force            Ghi đè nếu file đích đã tồn tại.
  -h, --help         Hiện trợ giúp này.
EOF
}

# ---------- parse args ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --article) ARTICLE="$2"; shift 2 ;;
    --book) BOOK="$2"; shift 2 ;;
    --subdir) SUBDIR="$2"; shift 2 ;;
    --slug) SLUG="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --alt) ALT="$2"; shift 2 ;;
    --width) WIDTH="$2"; shift 2 ;;
    --caption) CAPTION="$2"; shift 2 ;;
    --insert) INSERT=1; shift ;;
    --marker) MARKER="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --fresh) FRESH=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; while [[ $# -gt 0 ]]; do IMAGES+=("$1"); shift; done ;;
    *)
      if [[ "$1" == --* ]]; then
        echo "Unknown option: $1" >&2; exit 2
      fi
      IMAGES+=("$1"); shift ;;
  esac
done

if [[ ${#IMAGES[@]} -eq 0 ]]; then
  echo "Cần ít nhất một file ảnh." >&2
  usage >&2
  exit 2
fi

# validate images exist
for img in "${IMAGES[@]}"; do
  if [[ ! -f "$img" ]]; then
    echo "Không tìm thấy file ảnh: $img" >&2
    exit 2
  fi
done

# ---------- derive book/subdir/slug from article ----------
REPO_ROOT=""
if [[ -n "$ARTICLE" ]]; then
  # resolve repo root from script location
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  ARTICLE_ABS="$(cd "$(dirname "$ARTICLE")" && pwd)/$(basename "$ARTICLE")"
  if [[ ! -f "$ARTICLE_ABS" ]]; then
    echo "Không tìm thấy bài viết: $ARTICLE" >&2
    exit 2
  fi
  REL="${ARTICLE_ABS#$REPO_ROOT/}"
  if [[ "$REL" == "$ARTICLE_ABS" ]]; then
    echo "Bài viết không nằm trong repo book ($REPO_ROOT)." >&2
    exit 2
  fi
  if [[ -z "$BOOK" ]]; then
    BOOK="${REL%%/*}"
  fi
  REST="${REL#*/}"          # <subdir...>/<slug>.md
  if [[ -z "$SUBDIR" ]]; then
    SUBDIR="$(dirname "$REST")"
    [[ "$SUBDIR" == "." ]] && SUBDIR=""
  fi
  if [[ -z "$SLUG" ]]; then
    SLUG="$(basename "$REST" .md)"
  fi
fi

# fallbacks
[[ -z "$BOOK" ]] && BOOK="blogs"
[[ -z "$SLUG" ]] && SLUG="image"
# normalize subdir (remove leading ./)
SUBDIR="${SUBDIR#./}"

TARGET_DIR_REL="gitbook/blogs/${BOOK}"
if [[ -n "$SUBDIR" && "$SUBDIR" != "." ]]; then
  TARGET_DIR_REL="${TARGET_DIR_REL}/${SUBDIR}"
fi

# ---------- clone / update (skip in dry-run) ----------
clone_repo() {
  if [[ $FRESH -eq 1 && -d "$S3_DIR" ]]; then
    rm -rf "$S3_DIR"
  fi
  if [[ ! -d "$S3_DIR/.git" ]]; then
    mkdir -p "$(dirname "$S3_DIR")"
    if [[ -n "$TOKEN" ]]; then
      git clone "https://x-access-token:${TOKEN}@github.com/${S3_REPO}.git" "$S3_DIR" >/dev/null 2>&1
    else
      git clone "https://github.com/${S3_REPO}.git" "$S3_DIR" >/dev/null 2>&1
    fi
  fi
  if [[ -n "$TOKEN" ]]; then
    git -C "$S3_DIR" remote set-url origin "https://x-access-token:${TOKEN}@github.com/${S3_REPO}.git" >/dev/null 2>&1
  fi
  git -C "$S3_DIR" fetch origin main >/dev/null 2>&1 || true
  git -C "$S3_DIR" checkout main >/dev/null 2>&1 || true
  git -C "$S3_DIR" pull --ff-only origin main >/dev/null 2>&1 || true
}

if [[ $DRY_RUN -eq 0 ]]; then
  clone_repo
fi

# ---------- process each image ----------
COUNT=${#IMAGES[@]}
URLS=()
SNIPPETS=()
i=0
for img in "${IMAGES[@]}"; do
  i=$((i+1))
  ext="${img##*.}"
  ext="${ext,,}"
  if [[ -z "$ext" || "$ext" == "$img" ]]; then
    echo "Không xác định được đuôi file: $img" >&2
    exit 2
  fi

  # determine stem
  if [[ -n "$NAME" ]]; then
    stem="$NAME"
  else
    if [[ $COUNT -gt 1 ]]; then
      stem="${SLUG}-$(printf '%03d' "$i")"
    else
      stem="${SLUG}-001"
    fi
  fi

  # find free filename if collision (non-dry-run only; in dry-run assume free)
  if [[ $DRY_RUN -eq 0 ]]; then
    base_stem="$stem"
    n=1
    # if explicit name and exists, bump
    while [[ -e "$S3_DIR/$TARGET_DIR_REL/${stem}.${ext}" && ( $FORCE -eq 0 ) ]]; do
      n=$((n+1))
      stem="${base_stem}-$(printf '%03d' "$n")"
      # guard: avoid infinite if base already numbered; but okay
      if [[ $n -gt 999 ]]; then break; fi
    done
  fi

  target_rel="${TARGET_DIR_REL}/${stem}.${ext}"
  target_abs="$S3_DIR/$target_rel"

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] would copy: $img -> $target_rel"
  else
    mkdir -p "$(dirname "$target_abs")"
    cp -f "$img" "$target_abs"
  fi

  url="https://raw.githubusercontent.com/${S3_REPO}/main/${target_rel}"
  URLS+=("$url")

  # build snippet
  alt_attr=""
  [[ -n "$ALT" ]] && alt_attr=" alt=\"${ALT}\""
  width_attr=""
  [[ -n "$WIDTH" ]] && width_attr=" width=\"${WIDTH}\""
  img_tag="<img src=\"${url}\"${alt_attr}${width_attr}>"
  if [[ -n "$CAPTION" ]]; then
    snippet="<figure>${img_tag}<figcaption><p>${CAPTION}</p></figcaption></figure>"
  else
    snippet="<figure>${img_tag}<figcaption></figcaption></figure>"
  fi
  SNIPPETS+=("$snippet")
done

# ---------- commit & push ----------
if [[ $DRY_RUN -eq 0 ]]; then
  git -C "$S3_DIR" add -A
  if git -C "$S3_DIR" diff --cached --quiet; then
    echo "Không có thay đổi mới để commit (ảnh có thể đã tồn tại)."
  else
    git -C "$S3_DIR" commit -m "chore(s3-001): add images for ${SLUG} (${BOOK})" >/dev/null
    git -C "$S3_DIR" push origin main
    echo "Đã push lên ${S3_REPO}@main."
  fi
fi

# ---------- verify ----------
if [[ $DRY_RUN -eq 0 ]]; then
  for url in "${URLS[@]}"; do
    code="$(curl -s -o /dev/null -w '%{http_code}' "$url" 2>/dev/null || echo '000')"
    echo "verify: $url -> HTTP $code"
  done
fi

# ---------- insert into article ----------
if [[ $INSERT -eq 1 ]]; then
  if [[ -z "$ARTICLE_ABS" ]]; then
    echo "--insert cần --article." >&2
    exit 2
  fi
  combined=""
  for sn in "${SNIPPETS[@]}"; do
    combined="${combined}${sn}"$'\n'
  done
  if [[ -n "$MARKER" ]]; then
    tmp="$(mktemp)"
    awk -v snip="$combined" -v marker="$MARKER" '
      { print }
      $0 ~ marker { printf "%s", snip }
    ' "$ARTICLE_ABS" > "$tmp" && mv "$tmp" "$ARTICLE_ABS"
  else
    printf '\n%s\n' "$combined" >> "$ARTICLE_ABS"
  fi
  echo "Đã chèn snippet vào: $ARTICLE_ABS"
fi

# ---------- output ----------
echo ""
echo "=== Raw URLs ==="
for url in "${URLS[@]}"; do
  echo "$url"
done
echo ""
echo "=== Snippets ==="
for sn in "${SNIPPETS[@]}"; do
  echo "$sn"
done
echo ""
echo "Rollback: cd $S3_DIR && git revert HEAD && git push origin main  (hoặc xoá file + push)"
