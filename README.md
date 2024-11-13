# Tasks
A hub for task scripts

## Instructions
For those not familiar with git submodule, it is a way of syncing one repository to another as a folder.

More info: https://git-scm.com/book/en/v2/Git-Tools-Submodules

### To clone the repository to a new computer
`git clone git@github.com:coganlab/Tasks.git`

### To sync the sub-repositories
```
git submodule init
git submodule sync --recursive
git submodule update --recursive
```
