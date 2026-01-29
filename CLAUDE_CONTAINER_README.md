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

### First time setup
When you open the shell the first time for a new project, Claude will ask you about your login. When it shows an URL to open,
copy and paste that URL instead of clicking it, as it may not work correctly otherwise. The resulting passkey must then be copied
back from the browser into the shell. 

Subsequent usages of the shell in this project will then not require another login.

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

### Let Claude access screenshots
In theory, you can paste images from the clipboard into the Claude Code shell to let it analyze them. However, that does not work reliably with devcontainers (sometimes it works, but often not).
To make screenshot sharing easier with CC, there is a readonly hosting for a sharing folder, which is setup by the devcontainer.json:
It binds your host's folder `~/.claude_screenshots` to the container's `~/screenshots`.

## Extensions
### Docker in Docker
If you need docker inside your devcontainer, e.g. for testcontainers, add this to toplevel elements in the `devcontainer.json`:

```json
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },
```

## Troubleshooting
### Outdated docker container
Sometimes it may happen, that `claude-stop` and a rebuild do not update the used docker container. For instance, when you add new dependencies or commands to the Dockerfile and nothing changes, this is an indicator for an outdated docker container. 

Check your docker container (for instance via shell using `docker container list`), if the CREATED time matches your build time. If it is older, then there might have been some hickup and you have to delete the docker container yourself (e.g. `docker container rm ID`). Then simply start it again and connect with it.
