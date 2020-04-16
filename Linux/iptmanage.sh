#!/bin/bash

# +----------------------------------------------------------------------------------------------------+
# |  Copyright by Gracjan Mika ( https://gmika.pl ) and Patryk Potoczak ( https://github.com/toczak )  |
# |                                     IPTablesManage for Linux                                       |
# +----------------------------------------------------------------------------------------------------+

CONFIG_FILE="$( realpath ~/ )/IPTablesManager-config.txt"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "#!/bin/bash" > "$CONFIG_FILE"
fi

INSTALLED=false
dpkg -s iptables-persistent > /dev/null 2>&1 && INSTALLED=true

if [[ "$INSTALLED" == "false" ]]; then
  echo "To save IPTABLES configuration permanently (do not clear iptables when reboot) we need to install package \"iptables-persistent\"."
  read -p "Do you want to install this package now? [y/n] " INSTALLED
  if [[ "$INSTALLED" =~ ^y$ ]]; then
    sudo apt-get install iptables-persistent && INSTALLED=true || INSTALLED=false
    if [[ "$INSTALLED" == "false" ]]; then
      echo "Something went wrong... Package probably is not installed."
    else
      echo "Package has been successfully installed!"
    fi
  else
    echo "Package is not installed, operation canceled."
    INSTALLED=false
  fi
fi


COMMAND=""

selectChain ()
{
  local CANCEL=false
  local GOOD=false
  local CHAINSELECTED="<chain>"
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    GOOD=false

    if [ "$#" -eq "2" ]; then
      COMMAND="iptables -t $1 $2"
    else
      COMMAND="iptables -t $1 $2 $CHAINSELECTED $3"
    fi
    echo "========== TABLE $1 CHAIN =========="
    echo "Current prepared command:"
    echo "$COMMAND"
    echo "Select chain:"
    if [[ "$1" == "raw" || "$1" == "mangle" || "$1" == "filter" || "$1" == "nat" ]]; then echo "1) OUTPUT"; fi
    if [[ "$1" == "mangle" || "$1" == "filter" ]]; then echo "2) INPUT"; fi
    if [[ "$1" == "mangle" || "$1" == "filter" ]]; then echo "3) FORWARD"; fi
    if [[ "$1" == "raw" || "$1" == "mangle" || "$1" == "nat" ]]; then echo "4) PREROUTING"; fi
    if [[ "$1" == "mangle" || "$1" == "nat" ]]; then echo "5) POSTROUTING"; fi
    echo ""
    echo "e) Add current command to file"
    echo ""
    echo "0) Go back"
    
    while true
    do
      read -n 1 -p "Your choice: " MENUSELECTED
      echo ""
      echo ""
      case $MENUSELECTED in
        1 )
          if [[ "$1" == "raw" || "$1" == "mangle" || "$1" == "filter" || "$1" == "nat" ]]; then 
            CHAINSELECTED="OUTPUT"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        2 )
          if [[ "$1" == "mangle" || "$1" == "filter" ]]; then 
            CHAINSELECTED="INPUT"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        3 )
          if [[ "$1" == "mangle" || "$1" == "filter" ]]; then 
            CHAINSELECTED="FORWARD"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        4 )
          if [[ "$1" == "raw" || "$1" == "mangle" || "$1" == "nat" ]]; then 
            CHAINSELECTED="PREROUTING"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        5 )
          if [[ "$1" == "mangle" || "$1" == "nat" ]]; then 
            CHAINSELECTED="POSTROUTING"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        e )
          echo "$COMMAND" >> "$CONFIG_FILE"
          echo "Added to file: $COMMAND"
          CANCEL=true
          break
          ;;
        0 )
          CANCEL=true
          break
          ;;
        * )
          echo "Bad option, try again"
          ;;
      esac
    done
    if [[ "$GOOD" == "true" ]]; then
      if [ "$#" -eq "3" ]; then
        COMMAND="iptables -t $1 $2 $CHAINSELECTED $3"
      else
        COMMAND="iptables -t $1 $2 $CHAINSELECTED"
      fi

      if [[ "$2" == "-D" || "$2" == "-Z" || "$2" == "-F" ]]; then
        local SURE
        echo "$COMMAND"
        read -p "Add this command to file? [y/n] " SURE
        echo ""
        if [[ "$SURE" =~ ^y$ ]]; then
          echo "$COMMAND" >> "$CONFIG_FILE"
          echo "Added to file: $COMMAND"
        else
          echo "Operation canceled"
        fi
      else
        echo "PRZEKAŻE: $COMMAND"
      fi
      CANCEL=true
    fi
  done
}

addCommandToTableMenu ()
{
  local CANCEL=false
  local MENUSELECTED
  local POSITION
  while [[ "$CANCEL" == false ]]
  do
    COMMAND="iptables -t $1"
    echo "============= TABLE $1 ============="
    echo "Current prepared command:"
    echo "$COMMAND"
    echo "1) Append"
    echo "2) Delete by rule specification" # DONE
    echo "3) Delete by rule position" # DONE
    echo "4) Insert to specified position" 
    echo "5) Flush" # DONE
    echo "6) Zero" # DONE
    echo "7) Policy"
    echo ""
    echo "0) Go back"
    
    while true
    do
      read -n 1 -p "Your choice: " MENUSELECTED
      echo ""
      echo ""
      case $MENUSELECTED in
        1 )
          selectChain "$1" "-A"
          break
          ;;
        2 )
          read -p "Type content WITHOUT CHAIN which have to be removed: " POSITION
          if [[ "$POSITION" =~ ^.+[[:space:]].+$ ]]; then
            selectChain "$1" "-D" "$POSITION"
            break
          else
            echo "Bad command content"
          fi
          ;;
        3 )
          read -p "Position of rule to delete: " POSITION
          if [[ "$POSITION" =~ ^[0-9]+$ ]]; then
            selectChain "$1" "-D" "$POSITION"
            break
          else
            echo "Bad position NUMBER"
          fi
          ;;
        4 )
          read -p "Position of rule to insert: " POSITION
          if [[ "$POSITION" =~ ^[0-9]+$ ]]; then
            selectChain "$1" "-I" "$POSITION"
            break
          else
            echo "Bad position NUMBER"
          fi
          ;;
        5 )
          selectChain "$1" "-F"
          break
          ;;
        6 )
          selectChain "$1" "-Z"
          break
          ;;
        7 )
          selectChain "$1" "-P"
          break
          ;;
        0 )
          CANCEL=true
          break
          ;;
        * )
          echo "Bad option, try again"
          ;;
      esac
    done
  done
}

addTablesMenu ()
{
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    echo "============= ADD TO TABLE ============="
    echo "1) Add command to FILTER table"
    echo "2) Add command to NAT table"
    echo "3) Add command to MANGLE table"
    echo "4) Add command to RAW table"
    echo ""
    echo "0) Go back"
    
    while true
    do
      read -n 1 -p "Your choice: " MENUSELECTED
      echo ""
      echo ""
      case $MENUSELECTED in
        1 )
          addCommandToTableMenu "filter"
          break
          ;;
        2 )
          addCommandToTableMenu "nat"
          break
          ;;
        3 )
          addCommandToTableMenu "mangle"
          break
          ;;
        4 )
          addCommandToTableMenu "raw"
          break
          ;;
        0 )
          CANCEL=true
          break
          ;;
        * )
          echo "Bad option, try again"
          ;;
      esac
    done
  done
}

basicFirewall ()
{
echo "
iptables -P INPUT DROP

iptables -A INPUT -i lo -j ACCEPT
# iptables -A OUTPUT -o lo -j ACCEPT

iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP  # NULL PACKETS
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP   # SYN-FLOOD ATTACK
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP   # XMAS PACKETS

iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT   # HTTP
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT  # HTTPS

iptables -A INPUT -p tcp -m tcp --dport 587 -j ACCEPT  # SMTP
iptables -A INPUT -p tcp -m tcp --dport 465 -j ACCEPT  # SMTPS (SSL)
iptables -A INPUT -p tcp -m tcp --dport 110 -j ACCEPT  # POP3
iptables -A INPUT -p tcp -m tcp --dport 995 -j ACCEPT  # POP3S (SSL)
iptables -A INPUT -p tcp -m tcp --dport 143 -j ACCEPT  # IMAP
iptables -A INPUT -p tcp -m tcp --dport 993 -j ACCEPT  # IMAPS (SSL)

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
" >> "$CONFIG_FILE"
echo "DONE"
}

clearTablesMenu ()
{
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    echo "============== CLEAR TABLE ============="
    echo "If you have saved commands permanently then this only clear current loaded iptables but when you restart PC, the permanently settings will be loaded again."
    echo "If you want to clear the permanently settings, you need to first clear iptables, then save current iptables config permanently."
    echo ""
    echo "This option do not clear current chain policies"
    echo ""
    echo "1) Clear FILTER table"
    echo "2) Clear NAT table"
    echo "3) Clear MANGLE table"
    echo "4) Clear RAW table"
    echo ""
    echo "0) Go back"
    
    while true
    do
      read -n 1 -p "Your choice: " MENUSELECTED
      echo ""
      echo ""
      local SURE
      case $MENUSELECTED in
        [1234] )
          read -p "Are you sure? [y/n] " SURE
          if [[ ! "$SURE" =~ ^y$ ]]; then
            echo "Operation canceled"
            break
          fi
          ;;&
        1 )
          if [[ "$SURE" =~ ^y$ ]]; then
            sudo iptables -t filter -F
            echo "DONE"
          fi
          break
          ;;
        2 )
          if [[ "$SURE" =~ ^y$ ]]; then
            sudo iptables -t nat -F
            echo "DONE"
          fi
          break
          ;;
        3 )
          if [[ "$SURE" =~ ^y$ ]]; then
            sudo iptables -t mangle -F
            echo "DONE"
          fi
          break
          ;;
        4 )
          if [[ "$SURE" =~ ^y$ ]]; then
            sudo iptables -t raw -F
            echo "DONE"
          fi
          break
          ;;
        0 )
          CANCEL=true
          break
          ;;
        * )
          echo "Bad option, try again"
          ;;
      esac
    done
  done
}

showTablesMenu ()
{
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    echo "============= SHOW TABLES =============="
    echo "1) Show FILTER as table"
    echo "2) Show NAT as table"
    echo "3) Show MANGLE as table"
    echo "4) Show RAW as table"
    echo ""
    echo "5) Show FILTER as specification"
    echo "6) Show NAT as specification"
    echo "7) Show MANGLE as specification"
    echo "8) Show RAW as specification"
    echo ""
    echo "0) Go back"
    
    while true
    do
      read -n 1 -p "Your choice: " MENUSELECTED
      echo ""
      echo ""
      case $MENUSELECTED in
        1 )
          sudo iptables -t filter -L -v --line-numbers
          break
          ;;
        2 )
          sudo iptables -t nat -L -v --line-numbers
          break
          ;;
        3 )
          sudo iptables -t mangle -L -v --line-numbers
          break
          ;;
        4 )
          sudo iptables -t raw -L -v --line-numbers
          break
          ;;
        5 )
          sudo iptables -t filter -S
          break
          ;;
        6 )
          sudo iptables -t nat -S
          break
          ;;
        7 )
          sudo iptables -t mangle -S
          break
          ;;
        8 )
          sudo iptables -t raw -S
          break
          ;;
        0 )
          CANCEL=true
          break
          ;;
        * )
          echo "Bad option, try again"
          ;;
      esac
    done
    echo ""
  done
}

showFileWithNumbers ()
{
  local nr=0
  while IFS= read -r line
  do
    printf "%i. %s\n" $nr "$line"
    let nr++
  done < "$CONFIG_FILE"
}

showFile ()
{
  echo "============== SHOW FILE ==============="
  echo "Current file content:"
  showFileWithNumbers
  echo ""
}

removeLineFromFile ()
{
  local nr=0
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    echo "=========== REMOVE FROM FILE ==========="
    echo "Current file content:"

    nr=0
    while IFS= read -r line
    do
      printf "%i. %s\n" $nr "$line"
      let nr++
    done < "$CONFIG_FILE"

    echo ""
    echo "You can not delete line number 0!"
    echo "0) Go back"
    
    while true
    do
      read -p "Enter number of line or 0: " MENUSELECTED
      echo ""
      if [[ "$MENUSELECTED" =~ ^[1-9][0-9]*$ ]]; then
        if [ "$MENUSELECTED" -ge "$nr" ]; then
          echo "Entered number of line does not exist!"
        else
          let MENUSELECTED++
          sed -i $MENUSELECTED"d" "$CONFIG_FILE"
          echo "DONE"
          break
        fi
      else
        if [[ "$MENUSELECTED" =~ ^0$ ]]; then
          CANCEL=true
          break
        else
          echo "Bad option, try again"
        fi
      fi
    done
  done
}

loadFile ()
{
  local SURE
  echo "============== LOAD FILE ==============="
  echo "You want to load content from file"
  echo "$CONFIG_FILE"
  echo "to iptables."
  read -p "Are you sure? [y/n] " SURE
  if [[ ! "$SURE" =~ ^y$ ]]; then
    echo "Operation canceled"
    return
  fi
  echo "Reading from file..."
  sudo sh "$CONFIG_FILE"
  echo "DONE"
}

clearFile ()
{
  local SURE
  echo "============== CLEAR FILE =============="
  echo "You want to clear content of file"
  echo "$CONFIG_FILE"
  read -p "Are you sure? [y/n] " SURE
  if [[ ! "$SURE" =~ ^y$ ]]; then
    echo "Operation canceled"
    return
  fi
  echo "#!/bin/bash" > "$CONFIG_FILE"
  echo "DONE"
}

showMenu ()
{
  local CLOSE=false
  local MENUSELECTED
  while [[ "$CLOSE" == false ]]
  do
    echo "================= MENU ================="
    echo "i) Show all network interfaces"
    echo "1) Show specified table contents"
    echo "2) Add command to specified table"
    echo "3) Clear specified table"
    echo ""
    echo "4) Show current file content"
    echo "5) Load file to iptables"
    echo "6) Remove specified line from file"
    echo "7) Clear file content"
    if [[ "$INSTALLED" == "true" ]]; then echo "8) Save current iptables config permanently"; fi
    echo ""
    echo "9) Basic firewall"
    echo ""
    echo "0) Close program"
    
    while true
    do
      read -n 1 -p "Your choice: " MENUSELECTED
      echo ""
      echo ""
      case $MENUSELECTED in
        i )
          ifconfig -a
          break
          ;;
        1 )
          showTablesMenu
          break
          ;;
        2 )
          addTablesMenu
          break
          ;;
        3 )
          clearTablesMenu
          break
          ;;
        4 )
          showFile
          break
          ;;
        5 )
          loadFile
          break
          ;;
        6 )
          removeLineFromFile
          break
          ;;
        7 )
          clearFile
          break
          ;;
        8 )
          if [[ "$INSTALLED" == "false" ]]; then
            echo "Bad option, try again"
          else
            sudo iptables-save | sudo tee /etc/iptables/rules.v4
            echo "DONE"
          fi
          break
          ;;
        9 )
          basicFirewall
          break
          ;;
        0 )
          CLOSE=true
          break
          ;;
        * )
          echo "Bad option, try again"
          ;;
      esac
    done
  done
}

showMenu
exit 0