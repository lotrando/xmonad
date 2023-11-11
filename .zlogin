[[ -f ~/.zshrc ]] && source ~/.zshrc
[[ -t 0 && $(tty) == /dev/tty1 && ! $DISPLAY ]] && exec startx > /dev/null 2>&1
