FROM ubuntu:latest

ARG HOME=/root

# Packages
RUN apt-get update
RUN apt-get -y install fuse libfuse2
RUN apt-get -y install tree git wget curl make
RUN apt-get -y install unzip
RUN apt-get -y install zip

RUN usermod --shell /bin/bash root

# Sdkman, Java
RUN curl -s "https://get.sdkman.io" | bash
RUN /bin/bash -c "source /root/.sdkman/bin/sdkman-init.sh; sdk install java 18.0.2-zulu"

# Go
RUN wget https://go.dev/dl/go1.19.2.linux-arm64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.2.linux-arm64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"
RUN go install github.com/davidrjenni/reftools/cmd/fillstruct@latest
RUN go install golang.org/x/tools/cmd/goimports@latest

# NeoVim
RUN apt install software-properties-common -y
RUN add-apt-repository ppa:neovim-ppa/stable -y
RUN apt-get update
RUN apt-get -y install neovim

# Zsh
RUN wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | zsh || true

# Install Packer
RUN git clone --depth 1 "https://github.com/wbthomason/packer.nvim" "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"

RUN apt-get -y install sudo lua5.4 luarocks
RUN luarocks install luasocket
RUN apt-get -y install luajit

RUN mkdir -p $HOME/.config/nvim
COPY nvim $HOME/.config/nvim

# Install Plugins [might break .. https://github.com/wbthomason/packer.nvim/issues/502]
RUN date
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
RUN nvim --headless -c 'MasonInstall lua-language-server' -c q
RUN nvim --headless -c 'MasonInstall gopls' -c q
RUN nvim --headless -c 'MasonInstall goimports' -c q
RUN nvim --headless -c 'MasonInstall golangci-lint' -c q
RUN nvim --headless -c 'MasonInstall stylua' -c q

