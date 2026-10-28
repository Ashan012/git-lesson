#!/bin/bash
set -e

# Get current date
DATE=$(date +%Y-%m-%d)
BRANCH="lesson-${DATE}-$(date +%s)"

# Read lessons.json and pick random lesson
LESSON=$(DATE=$DATE node -e "
const lessons = require('./lessons.json');
const idx = Math.floor(Math.random() * lessons.length);
const l = lessons[idx];
const fs = require('fs');
const path = require('path');
const dir = './lessons';
if(!fs.existsSync(dir)) fs.mkdirSync(dir);
const out = '# ' + l.title + '\n\n' + l.content + '\n\n*Date: ' + process.env.DATE + '*\n';
const fname = path.join(dir, 'lesson-' + process.env.DATE + '-' + idx + '.md');
fs.writeFileSync(fname, out);
process.stdout.write(l.title);
")

echo "Selected: $LESSON"

# Create branch, commit, push
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

git checkout -b "$BRANCH"
git add lessons/lesson-*.md
git commit -m "Add daily lesson: $LESSON"
git push -u origin "$BRANCH" || git push origin "$BRANCH"

# Create PR (use default branch)
DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
PR_URL=$(gh pr create --title "Daily Lesson: $LESSON" --body "Auto-generated daily Git lesson for $DATE" --base "$DEFAULT_BRANCH" --head "$BRANCH")
echo "PR created: $PR_URL"
echo "$PR_URL" > pr_url.txt
