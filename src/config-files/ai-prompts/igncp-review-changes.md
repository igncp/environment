---
agent: agent
model: GPT-5.4
---
Review the content of the diff for the current changes by doing `GIT_PAGER='' git diff HEAD`. Summarize the changes and specially try to find obvious mistakes or quick wins. If you find any, suggest a fix for them. If you are suggesting any change, don't do the change, just mention the suggested changes and stop the process. If no suggestions, commit the changes using Traditional Chinese, preferably using Mandarin, giving a summary. Don't push to the remote. When commiting, don't add any extra co-authored line.
