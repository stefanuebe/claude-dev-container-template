Simple setup to use Claude Code on your local machine in a devcontainer. 

Inspired by Claude Code's original devcontainer setup. Most important change is, that the firewall is not active and claude has priviliged rights inside the container.

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
