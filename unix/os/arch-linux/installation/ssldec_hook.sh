# Modified from: https://bbs.archlinux.org/viewtopic.php?pid=947805#p947805
# To place in `/lib/initcpio/hooks/ssldec`

run_hook ()
{
  local encfile decfile attempts prompt badpassword poweroffmsg dev arg1 arg2 retcode password

  if [ "x${ssldec}" != "x" ]; then
    encfile="/enc_keyfile.bin"
    decfile="/crypto_keyfile.bin"

    attempts="3"

    prompt="Enter password: "
    badpassword="Password incorrect"
    poweroffmsg="Try again later. Power off."

    dev="$(echo "${ssldec}" | cut -d: -f1)"
    arg1="$(echo "${ssldec}" | cut -d: -f2)"
    arg2="$(echo "${ssldec}" | cut -d: -f3)"

    if poll_device "${dev}" "${rootdelay}"; then
      case "${arg1}" in
        *[!0-9]*)
          mkdir /mntkey
          mount -r -t "${arg1}" "${dev}" /mntkey
          dd if="/mntkey/${arg2}" of="${encfile}" >/dev/null 2>&1
          umount /mntkey
          rm -rf /mntkey
          ;;
        *)
          dd if="${dev}" of="${encfile}" bs=1 skip="${arg1}" count="${arg2}" >/dev/null 2>&1
          ;;
      esac
    fi

    if [ -f "${encfile}" ]; then
      while true; do
        read -rsp "${prompt}" password
        openssl aes256 -pass pass:"${password}" -d -in "${encfile}" -out "${decfile}" >/dev/null 2>&1
        retcode="$?"

        if [ "${retcode}" != "0" ]; then
          sleep 2
          attempts=$(( ${attempts} - 1 ))
          [ "${attempts}" == "0" ] && echo -e "\n${poweroffmsg}" && poweroff -f
          echo -e "\n${badpassword}\n"
        else
          break
        fi

        rm -f "${encfile}"
      done
    else
      echo "Encrypted keyfile could not be opened. Reverting to 'encrypt' hook."
    fi
  fi
}
