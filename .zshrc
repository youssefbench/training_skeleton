# Set up the prompt

autoload -Uz promptinit
promptinit
# prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

source /etc/profile

# colors
autoload -U colors && colors
PS1="%{$fg[yellow]%}%m %{$fg[magenta]%}[%~]%{$reset_color%}$ "
RPROMPT=""
RPROMPT="%{$fg[green]%} [%D{%L:%M:%S}] %{$reset_color%} "$RPROMPT

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/public/apps/anaconda3/2022.05/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/public/apps/anaconda3/2022.05/etc/profile.d/conda.sh" ]; then
        . "/public/apps/anaconda3/2022.05/etc/profile.d/conda.sh"
    else
        export PATH="/public/apps/anaconda3/2022.05/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

alias gs='git status'


# USEFUL aliases
# Count number of files in folder
alias nb="ls | wc -l"

## get rid of command not found ##
alias cd..='cd ..'
 
## a quick way to get out of current directory ##
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'

## Colorize the ls output ##
alias ls='ls --color=auto'
 
## Use a long listing format ##
alias ll='ls -la'
 
## Show hidden files ##
alias l.='ls -d .* --color=auto'

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'


grep -i --color memory /var/log/Xorg.0.log#16: Add safety nets
# do not delete / or prompt if deleting more than 3 files at a time #
alias rm='rm -I --preserve-root'
 
# confirmation #
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

alias gpu='nvidia-smi '

# SLURM aliases
# https://www.internalfb.com/intern/wiki/FAIR/Platforms/Clusters/FAIRClusters/SLURM_on_FAIR_cluster/#useful-aliases

alias v100="srun --gpus-per-node=1 --partition=devlab --time=4320 --cpus-per-task 10 --constraint='volta32gb' --pty /bin/bash -l"

# sj: show info for a given job ID
# Usage: sj <job_id>
alias sj='scontrol show jobid -dd '

# sq: *very verbose* squeue, automatically paginated
alias sq='squeue -o            "%.8Q %.10i %.3P %.9j %.6u %.2t %.16S %.10M %.10l %.5D %.12b %.2c %.4m %R" -S -t,-p,i | less -N '

# mj: show a list of all my jobs
# Usage: mj
alias mj='squeue -u $USER -o   "%.8Q %.10i %.3P %.9j %.6u %.2t %.16S %.10M %.10l %.5D %.12b %.2c %.4m %R" -S -t,-p,i | less -N '

# sp: show a list of pending jobs across the cluster,
# in decreasing order of SLURM priority
# Usage: sp
alias sp='squeue -t PENDING -o "%.8Q %.10i %.3P %.9j %.6u %.2t %.16S %.10M %.10l %.5D %.12b %.2c %.4m %R" -S -t,-p,i | less -N '

# cj: cancel a job
# Usage: cj <job_id>
# OR to cancel ALL your jobs (be careful!): cj -u $USER
alias cj='scancel '

alias perm="sacctmgr -p list associations user=$USER format=Name,Account,Priority,GraceTime,GrpTRES,GrpJobs,GrpSubmit,GrpSubmit,MaxTRES,MaxTRESPerUser,MaxJobsPU,tres tree | column -ts'|' "

# rp: randomly reassign jobs from one partition to another, up to a specified limit
# Usage: rp <old_partition> <new_partition> <job_limit>
function rp {
    squeue -u $USER -t PENDING -p "$1" -o '%i' -h | \
        sort -R | \
        tail -n "$3" | \
        xargs -n 1 -I '{}' \
            scontrol update jobid='{}' partition="$2" \
    ;
}
