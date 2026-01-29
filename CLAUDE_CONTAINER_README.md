Simple setup to use Claude Code on your local machine in a devcontainer. 

Inspired by [Claude Code's original devcontainer setup](https://github.com/anthropics/claude-code/tree/main/.devcontainer). Most important change is, that the firewall is not active and claude has priviliged rights inside the container.

_Note: You do not find a normal README.md here, but this file instead. since this repo ist intended as a template for other projects. And we do
not want to override potential other READMEs._

## Disclaimer / Warning
Before you do anything with the files provided here, be aware, that devcontainers may have unknown (or known) bugs, that may allow
Claude to break out and do unwanted things with your host machine. Also be aware, that the given setup has no firewall rules enabled 
and Claude can use sudo inside the devcontainer.

**Everything you do you do on your own risk, I do not give any guarantees
and do not take any responsibility for what you do with this template / repo content.** 


## How to get
### Github template
Fork this repo, mark it as a template in the project settings and create a new repo based on it. 

### Integrate into an existing project
Copy the following things into your project root:
* .claude
* .devcontainer
* .mcp.json

Regarding the specific files and what they are used for, feel free to google or use an AI to explain :)

## How to use
You can either use the devcontainer in an IDE, that supports them (like VSCode) or run it in the shell/terminal. 

### Shell shortcuts
Here are some useful shortcuts, that can be added to allow easier setup and access:

```shell

# ----------------------------------------------
# Claude DevContainer Shortcuts
# ----------------------------------------------

# 1. Startup and run in background
alias claude-up="devcontainer up --workspace-folder ."

# 2. Open shell
alias claude-shell="devcontainer exec --workspace-folder . zsh"

# 3. Soft-Rebuild (only devcontainer.json changes)
alias claude-update="devcontainer up --workspace-folder . --remove-existing-container"

# 4. Hard-Rebuild (on Dockerfile changes - takes longer)
alias claude-rebuild="devcontainer build --workspace-folder ."

# 4. Hard-Rebuild without cache (on Dockerfile changes - takes even longer ;)
alias claude-rebuild-full="devcontainer build --workspace-folder . --no-cache"


# 5. Smart Stop function
# Finds and stops the container "owned" by the current folder
claude-stop() {
    local container_id=$(docker ps -q --filter "label=devcontainer.local_folder=$PWD")

    if [ -z "$container_id" ]; then
        echo "❌ No running dev container found for this folder / project."
    else
        echo "🛑 Stopping container $container_id ..."
        docker stop $container_id
        echo "✅ Done."
    fi
}

```
