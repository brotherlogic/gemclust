---
description: Automatically push changes to a feature branch after finishing any task
---
When finishing any task, you MUST automatically follow these steps to commit and push the changes to a new feature branch before completing the task. 

1. Come up with a short, descriptive name for the feature branch based on the task (e.g., `feature/bootstrap-flux`).
2. Create and switch to the new feature branch:
`git checkout -b <branch-name>`
3. Add all modified and new files:
`git add .`
4. Commit the changes with a clear summary:
`git commit -m "<Short summary of the completed task>"`
5. Push the new branch to the remote repository:
`git push -u origin <branch-name>`

You should run these commands using the `run_command` tool.
