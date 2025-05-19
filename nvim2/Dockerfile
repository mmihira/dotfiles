ARG USERHANDLE=mihira
FROM --platform=linux/arm64 ubuntu:noble

# Install Dependencies
RUN apt-get update
RUN apt-get install -y cmake gettext ninja-build git ripgrep fzf build-essential curl unzip nodejs npm python3 python3-venv clangd

# Install Neovim latest stable
RUN \
  set -e; \
  mkdir -p /opt; \
  git clone https://github.com/neovim/neovim.git --branch stable; \
  cd neovim; \
  make CMAKE_BUILD_TYPE=Release; \
  make install

RUN \
  curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-arm64.tar.gz; \
  tar -C /opt -xzf nvim-linux-arm64.tar.gz; \
  chmod +x /opt/nvim-linux-arm64/bin/nvim

# Configure datetime
ENV TZ=Australia/Melbourne

# Configure NVIM paths
RUN mkdir -m 777 -p /local/share /local/cache /local/state
ENV XDG_DATA_HOME=/local/share
ENV XDG_CACHE_HOME=/local/cache
ENV XDG_STATE_HOME=/local/state

# Configure PATH
ENV PATH=$PATH:/usr/local/go/bin:/opt/nvim-linux-arm64/bin

# Install LazyGit
ENV LAZYGIT_VERSION="0.45.2"
RUN \
  curl -L https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz | \
  tar -C /usr/local/bin -xzf - lazygit;

# Create user with same home directory as Mac
ARG USERHANDLE
ENV USER_ID=${USERHANDLE}

RUN echo "Creating user $USER_ID with UID 502 and group staff"

RUN useradd --uid 502 --group staff "$USER_ID" --home "/Users/$USER_ID"
RUN usermod -a -G root "$USER_ID" 
RUN mkdir -p "/Users/$USER_ID"
RUN chown -R "$USER_ID:staff" "/Users/$USER_ID"

USER "$USER_ID"

CMD ["/bin/bash", "-c", "echo 'Starting dev container'; sleep infinity"]

VOLUME ["/Users/${USERHANDLE}", "/local/share"]
