base_dir=$(pwd)

# 1. 普通仓库（有 .git 子目录）
find "$base_dir" -type d -name ".git" | while read -r gitdir; do
  repo_dir=$(dirname "$gitdir")
  echo -e "\n进入 $repo_dir 执行操作..."
  cd "$repo_dir" || continue

  echo "移除 origin 远程仓库..."
  git remote remove origin 2>/dev/null
  echo "查找 dangling commit..."
  dangling_commit=$(git fsck --full | grep 'dangling commit' | head -n 1 | awk '{print $3}')
  if [ -z "$dangling_commit" ]; then
    echo "未找到 dangling commit"
    cd "$base_dir"
    continue
  fi
  echo "找到 dangling commit: $dangling_commit"
  echo "更新 master 分支指向 dangling commit..."
  git update-ref refs/heads/master "$dangling_commit"
  echo "已将 master 分支指向 $dangling_commit"
  cd "$base_dir"
done

# 2. 裸仓库（目录本身以 .git 结尾）
find "$base_dir" -type d -name "*.git" | while read -r dir; do
  # 跳过普通仓库的 .git 子目录
  if [ -d "$dir/refs" ] && [ ! -d "$dir/../.git" ]; then
    echo -e "\n进入裸仓库 $dir 执行操作..."
    cd "$dir" || continue

    echo "移除 origin 远程仓库..."
    git remote remove origin 2>/dev/null
    echo "查找 dangling commit..."
    dangling_commit=$(git fsck --full | grep 'dangling commit' | head -n 1 | awk '{print $3}')
    if [ -z "$dangling_commit" ]; then
      echo "未找到 dangling commit"
      cd "$base_dir"
      continue
    fi
    echo "找到 dangling commit: $dangling_commit"
    echo "更新 master 分支指向 dangling commit..."
    git update-ref refs/heads/master "$dangling_commit"
    echo "已将 master 分支指向 $dangling_commit"
    cd "$base_dir"
  fi
done