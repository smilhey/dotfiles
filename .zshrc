export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

path+=('/home/smilhey/.cargo/bin')
path+=('/home/smilhey/.local/bin')

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/smilhey/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/smilhey/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/smilhey/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/smilhey/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/home/smilhey/miniforge3/etc/profile.d/mamba.sh" ]; then
    . "/home/smilhey/miniforge3/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

