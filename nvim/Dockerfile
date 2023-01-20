FROM ubuntu:latest
ARG HOME=/root

# Packages
RUN apt-get update
RUN apt-get -y install zsh tree git wget curl make unzip zip
RUN apt-get -y install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config 
RUN git clone -b stable --depth 1 https://github.com/neovim/neovim.git $HOME/neovim
RUN git clone --depth 1 https://github.com/mmihira/dotfiles.git 

# Install Neovim
WORKDIR $HOME/neovim
RUN git checkout stable &&  make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/usr/local/bin install
WORKDIR $HOME

# Sdkman, Java
RUN curl -s "https://get.sdkman.io" | bash
RUN /bin/bash -c "source /root/.sdkman/bin/sdkman-init.sh; sdk install java 18.0.2-zulu"

# Setup zsh
RUN rm /root/.zshrc
RUN ln -s ./dotfiles/mac/.zshrc /root/.zshrc

# Go
RUN wget https://go.dev/dl/go1.19.2.linux-arm64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.2.linux-arm64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Packer
RUN git clone --depth 1 "https://github.com/wbthomason/packer.nvim" "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"

# Copy over nvim config
RUN mkdir -p /root/.config/nvim
COPY nvim /root/.config/nvim
RUN ln -s /usr/local/bin/bin/nvim /usr/local/bin

# Install Plugins [might break .. https://github.com/wbthomason/packer.nvim/issues/502]
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# Set env variables
ENV TERM screen-256color

# Mason install LSPs
RUN nvim --headless -c 'MasonInstall jdtls' -c q
RUN nvim --headless -c 'MasonInstall lua-language-server' -c q
RUN nvim --headless -c 'MasonInstall gopls' -c q
RUN nvim --headless -c 'MasonInstall goimports' -c q
RUN nvim --headless -c 'MasonInstall golangci-lint' -c q
RUN nvim --headless -c 'MasonInstall stylua' -c q

CMD ["zsh"]
