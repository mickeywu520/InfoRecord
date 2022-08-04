# repo upload issue record
## must create branch via repo command not git command.
###    1. create branch by repo command, repo start "branch name" .
      Ex: repo start work .
###    2. checkout your branch
      Ex: git checkout work
###    3. add your changed things.
      Ex: git add xxx/xxx/xxx.xxx
###    4. commit your comment
      Ex: git commit -m "Update something"
###    5. repo upload .
####      Ex: repo upload .
      if encounter below error, using --no-verity, due to not match Google rule.
####      Ex: repo upload --no-verify .
      [FAILED] commit_msg_test_field
        Commit message is missing a "Test:" line.  It must match the
        following case-sensitive regex:
