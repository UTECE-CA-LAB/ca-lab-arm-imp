for use just turn off the incremental synthesis and run this command on vivado:
``` bash
generate_target all [get_ips]
```

for switch between the branches and start from last commit:
``` bash 
git fetch --all
git switch -f <branch-name>
git reset --hard origin/<branch-name>
git clean -fdx
git status
```
