if [ -f $(brew --prefix)/etc/bash_completion ]; then
. $(brew --prefix)/etc/bash_completion
fi

#PS1 manipulation
PROMPT_COMMAND=__prompt_command

__parse_git_branch() {
     git branch 2> /dev/null | awk '/\*/ {print $2}'
}

__parse_venv() {
    echo ${VIRTUAL_ENV} | awk -F "/" '{print $NF}'
}

__prompt_command() {
    local exit_code="$?"
    PS1=""
    local default='\[\e[0m\]'
    local red='\[\e[0;31m\]'
    local green='\[\e[0;32m\]'
    local yellow='\[\e[0;33m\]'
    local light_green='\[\e[0;92m\]'
    local blue='\[\e[0;34m\]'
    local light_blue='\[\e[0;94m\]'
    PS1+="${light_blue}<${default}"
    if [ $exit_code != 0 ]; then
        PS1+="${red}${exit_code}${default}"
    else
        PS1+="${green}${exit_code}${default}"
    fi
    PS1+="${light_blue}>${default}"
    local user="${blue}\u${default}"
    local machine="${blue}\h${default}"
    local at="${light_blue}@${default}"
    local current_dir="${yellow}\w>${default}"
    local current_time="${light_blue}[${default}${green}\t${light_blue}]${default}"
    local git_branch=`__parse_git_branch`
    if [ ! -z "${git_branch}" ]; then
        local git_branch="${light_blue}(${green}${git_branch}${light_blue})"
    fi
    local venv_name=`__parse_venv`
    if [ ! -z "${venv_name}" ]; then
        PS1+="${light_blue}(${green}${venv_name}${light_blue})${default}"
    fi
    PS1+="${current_time}${user}${at}${machine}${git_branch}${default}${current_dir} "
}

presto-tunnel() {
    local ssh_server=${1}
    local remote_host=${2}
    ssh -f centos@${ssh_server} -L 8080:${remote_host}:8080 -N
}

export PRESTO_HOME=~/src/varada
export PYTHONPATH=${PRESTO_HOME}/presto-varada/systemtests
export PATH=${PATH}:${PRESTO_HOME}/presto-varada/bin
export EDITOR=nano
ssh-add ~/.ssh/${USER}-varada-private
alias ll='ls -lashG'
alias git='LANG=en_US git'
alias build='cd ~/vagrant/vbox; vagrant ssh -c "cd /root/src/varada; presto-varada/scripts/mvn_client.sh"; cd - > /dev/null'
alias clean_build='cd ~/vagrant/vbox; vagrant ssh -c "cd /root/src/varada; presto-varada/scripts/mvn_client_clean.sh; presto-varada/scripts/mvn_client.sh"; cd - > /dev/null'
alias vdbg_build='cd ~/vagrant/vbox; vagrant ssh -c "cd /root/src/varada; presto-varada/scripts/mvn_client_vdbg.sh"; cd - > /dev/null' 
alias lc="echo 'load presto-admin config: ~/.varada.conf'; source ~/.varada.conf"
alias deploy="~/src/varada/presto-varada/scripts/deploy; lc"
alias deploy_dont_test="~/src/varada/presto-varada/scripts/deploy_dont_test; lc"
nlc() {
    cd ~/src/varada/presto-varada/terraform/cluster
    source ~/src/varada/presto-varada/bin/.vcstate
    export PRESTO_ADMIN_CONFIG_DIR=$(terraform output -state ${VC_STATE} presto_admin_dir)
    cd - > /dev/null
}
. ~/src/varada-venv/bin/activate
