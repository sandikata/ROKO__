# ----------------------------
# ZSH Shell definitions.
# ----------------------------
 
export ZSH=/usr/share/zsh/site-contrib/oh-my-zsh
export ZSHPLUGINS=/home/zsh-plugins

# jonathan junkfood
ZSH_THEME="jonathan"
 
DISABLE_AUTO_UPDATE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
 
plugins=( zsh-completions sprunge sudo git git-prompt git-extras colorize )
 
source $ZSH/oh-my-zsh.sh
source $ZSHPLUGINS/zsh-syntax-highlighting-filetypes.zsh
source $ZSHPLUGINS/dirhistory.plugin.zsh
source $ZSHPLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source $ZSHPLUGINS/notification.plugin.zsh
source $ZSHPLUGINS/you-should-use.plugin.zsh
source $ZSHPLUGINS/zsh-autosuggestions.zsh

#autoload -U colors
#colors

autoload -U compinit
compinit 
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*:descriptions' format '%U%B%d%b%u' 
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b' 

# -------------------
# User configuration.
# -------------------
 
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/bin
 
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

alias upgrade='emerge -uDNa --with-bdeps=y @world'
alias upgrade-check='emerge -uDNp --with-bdeps=y @world'
alias world='emerge -ea @world'
alias world-check='emerge -ep @world'
alias clean-needless='emerge -ac'
alias clean-needless-check='emerge -pc'
alias bios='[ -f /usr/sbin/dmidecode ] && sudo -v && echo -n "Motherboard" && sudo /usr/sbin/dmidecode -t 1 | grep "Manufacturer\|Product Name\|Serial Number" | tr -d "\t" | sed "s/Manufacturer//" && echo -ne "\nBIOS" && sudo /usr/sbin/dmidecode -t 0 | grep "Vendor\|Version\|Release" | tr -d "\t" | sed "s/Vendor//"'
alias vpenis='curl -s https://raw.githubusercontent.com/neechbear/vpenis/master/vpenis.pl | sudo perl'

local _myhosts
_myhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} )
zstyle ':completion:*' hosts $_myhosts

#prompt gentoo

autoload -U zutil
 
#export LANG=pt_BR.UTF-8
 
HISTFILE=~/.zsh_history
HISTSIZE=5000
export HISTSIZE=5000
export SAVEHIST=$HISTSIZE
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
 
alias nano='nano -w'
alias editor='nano'
export EDITOR=nano
 
eval $(dircolors -b $HOME/.dircolors)
 
# requer o pacote: grc (# emerge -av app-misc/grc )
GRC=`which grc`
if [ "$TERM" != dumb ] && [ -n "$GRC" ]
then
    alias colourify="$GRC -es --colour=auto"
    alias cfg='colourify ./configure'
    alias configure='colourify ./configure'
    alias diff='colourify diff'
#    alias make='colourify make'
    alias gcc='colourify gcc'
    alias g++='colourify g++'
    alias as='colourify as'
    alias gas='colourify gas'
    alias ld='colourify ld'
    alias netstat='colourify netstat'
    alias ping='colourify ping'
    alias traceroute='colourify /usr/sbin/traceroute'
    alias head='colourify head'
    alias tail='colourify tail'
    alias dig='colourify dig'
    alias mount='colourify mount'
    alias ps='colourify ps'
    alias mtr='colourify mtr'
    alias df='colourify df'
    alias nmap='colourify nmap'
fi

# unset useless variables
unset PERL5LIB ; unset PERL_LOCAL_LIB_ROOT ; unset PERL_MB_OPT ; unset PERL_MM_OPT
 
# Mapa de teclado que utilizo.
#setxkbmap -model abnt2 -layout br -variant abnt2
#setxkbmap -option terminate:ctrl_alt_bksp
 
# Informações do sistema, remova essas linhas se desejar.
cat /etc/[A-Za-z]*[_-][rv]e[lr]*
echo ""
uname -a
echo ""
uptime
echo ""
