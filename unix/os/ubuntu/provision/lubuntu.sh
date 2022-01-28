# lubuntu START

cat >> ~/.shell_aliases <<"EOF"
LXPANEL_FILE="$HOME/.config/lxpanel/Lubuntu/panels/panel"
alias LubuntuPanelSetAutohide='sed -i "s/  autohide=.$/  autohide=1/" "$LXPANEL_FILE" && lxpanelctl restart'
alias LubuntuPanelSetNoAutohide='sed -i "s/  autohide=.$/  autohide=0/" "$LXPANEL_FILE" && lxpanelctl restart'
EOF

# lubuntu END
