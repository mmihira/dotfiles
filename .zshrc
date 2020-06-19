# Path to your oh-my-zsh installation.
export ZSH=/home/mihira/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="lambda"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# User configuration
# export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
# export MANPATH="/usr/local/man:$MANPATH"
source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias c="clear"
alias bers="bundle exec rspec"
alias ber="bundle exec rake"
alias br="bin/rake"
alias brs="bin/rspec"
alias vim=nvim
alias nvim=nvim.appimage
alias xo="xdg-open $1"

eval "$(fasd --init auto)"

# Make CTRL-Z background things and unbackground them.
function fg-bg() {
  if [[ $#BUFFER -eq 0 ]]; then
    fg
  else
    zle push-input
  fi
}
zle -N fg-bg
bindkey '^Z' fg-bg

export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="/home/mihira/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export MAMMON_UPDATE_PATH=~/Downloads
export MAMMON_DATABASE="~/Dropbox/Finance/mammon"

export PATH="$HOME/.cargo/bin:$PATH"
source ~/.ssh/env_keys.sh
export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"

export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$(yarn global bin):$PATH"

export PATH=$PATH:/usr/local/go/bin
export GOPATH="/home/mihira/c/go"
export PATH=$PATH:$GOPATH/bin

# Lombok
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

alias mux="tmuxinator"
alias vi="vim"

# Syntax highlighting
# To installhttps://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#
# echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

# Bash completion
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /tmp/mc mc

fpath+=('/home/mihira/.nvm/versions/node/v8.11.3/lib/node_modules/pure-prompt/functions')
autoload -U promptinit; promptinit
prompt pure

export GRAPHVIZ_DOT=/usr/bin/dot

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/mihira/.sdkman"
[[ -s "/home/mihira/.sdkman/bin/sdkman-init.sh" ]] && source "/home/mihira/.sdkman/bin/sdkman-init.sh"

[ -s "/home/mihira/.jabba/jabba.sh" ] && source "/home/mihira/.jabba/jabba.sh"
