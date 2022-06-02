export PATH=$PATH:~/bin

#export TERM='xterm-256color'
export EDITOR='gvim'

source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh
chruby 2.3.0

# Gradle
if [ -d "$HOME/opt/gradle" ]; then
    export GRADLE_HOME="$HOME/opt/gradle"
    PATH="$PATH:$GRADLE_HOME/bin"
fi

#fasd
eval "$(fasd --init auto)"

# Oculo
alias ocdb='sudo -u postgres psql oculo_dev'

#
gsettings set org.gnome.desktop.default-applications.terminal exec /usr/bin/zsh
gsettings set org.gnome.desktop.default-applications.terminal exec-arg ""


##############################################################################
########################### bash-it related scripts ##########################
##############################################################################


# Path to the bash it configuration
export BASH_IT="/home/mihira/.bash_it"

# Lock and Load a custom theme file
# location /.bash_it/themes/
export BASH_IT_THEME='simple'

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
# export BASH_IT_REMOTE='bash-it'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/xvzf/vcprompt
#export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# Load Bash It
source $BASH_IT/bash_it.sh

# added by Anaconda3 4.1.1 installer
export PATH="/home/mihira/anaconda3/bin:$PATH"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
. "$HOME/.cargo/env"
