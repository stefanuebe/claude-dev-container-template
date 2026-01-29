
# ----------------------------------------------
# Claude DevContainer Shortcuts
# ----------------------------------------------

# 1. Starten (im Hintergrund)
alias claude-up="devcontainer up --workspace-folder ."

# 2. Verbinden (Zsh öffnen) - Das hattest du dir gewünscht
alias claude-shell="devcontainer exec --workspace-folder . zsh"

# 3. Soft-Rebuild (nur devcontainer.json Änderungen)
alias claude-update="devcontainer up --workspace-folder . --remove-existing-container"

# 4. Hard-Rebuild (Dockerfile Änderungen - dauert länger)
alias claude-rebuild="devcontainer build --workspace-folder ."

# 4. Hard-Rebuild (Dockerfile Änderungen - dauert noch länger)
alias claude-rebuild-full="devcontainer build --workspace-folder . --no-cache"


# 5. Smart Stop Funktion
# Findet und stoppt den Container, der zum aktuellen Ordner gehört
claude-stop() {
    # Das CLI setzt das Label 'devcontainer.local_folder', das nutzen wir zum Finden
    local container_id=$(docker ps -q --filter "label=devcontainer.local_folder=$PWD")

    if [ -z "$container_id" ]; then
        echo "❌ Kein laufender Dev-Container für diesen Ordner gefunden."
    else
        echo "🛑 Stoppe Container $container_id ..."
        docker stop $container_id
        echo "✅ Erledigt."
    fi
}
