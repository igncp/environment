# dotnet-core START

# Only tested on Arch
if [ ! -d /usr/share/dotnet/ ]; then
  install_system_package dotnet-runtime
  install_system_package dotnet-sdk
fi

cat >> ~/.shellrc <<"EOF"
export PATH="$PATH:$HOME/.dotnet/tools"
DOTNET_CLI_TELEMETRY_OPTOUT=1
EOF

cat >> ~/.shell_aliases <<"EOF"
alias DotnetRun='dotnet run'
EOF

install_vim_package OmniSharp/omnisharp-vim

# dotnet-core END
