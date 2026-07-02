FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG USERNAME=vscode

# software-properties-common is installed at runtime by update-repositories.sh
# (avoids apt during image build, which fails when Docker DNS is misconfigured)

# Set up bash history
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir -p /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $USERNAME:$USERNAME /commandhistory \
    && echo "$SNIPPET" >> "/home/$USERNAME/.bashrc" \
    && echo "$SNIPPET" >> "/root/.bashrc"

CMD ["sleep", "infinity"]
