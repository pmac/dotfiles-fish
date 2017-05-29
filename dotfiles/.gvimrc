set columns=80
set lines=50

set guioptions=cig

if has("macunix")
    set guifont=Monoid:h11
elseif has("unix")
    set guifont=DejaVu\ Sans\ Mono\ 12
    set guioptions+=a " Automatically add selections to the Xorg paste buffer
else
    set guifont=Consolas:h9:cANSI
endif
