export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="lambda"

plugins=(git)

source $ZSH/oh-my-zsh.sh
eval $(/opt/homebrew/bin/brew shellenv)

# FASD
eval "$(fasd --init auto)"

# Bash completion
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /tmp/mc mc

# For CTRL-R
# https://github.com/junegunn/fzf
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export CODE_DIR="$HOME/c"
export GOPATH="$HOME/c/go"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:/usr/bin
export PATH="$(python3 -m site --user-base)/bin:$PATH"

[ -s ~/.ssh/env_keys.sh ] && source ~/.ssh/env_keys.sh

# For nvim,vim
export XDG_CONFIG_HOME="$HOME/.config"

# Lombok
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

alias vim=nvim
alias mux="tmuxinator"
alias vi="vim"

fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
[ -s "$HOME/.jabba/jabba.sh" ] && source "$HOME/.jabba/jabba.sh"

# bun completions
[ -s "/Users/mihira/.bun/_bun" ] && source "/Users/mihira/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

