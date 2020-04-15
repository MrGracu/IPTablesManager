#!/bin/bash

CONFIG_FILE="$( realpath ~/ )/IPTablesManager-config.txt"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "#!/bin/bash" > "$CONFIG_FILE"
fi

COMMAND=""

addCommandToTableMenu ()
{
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    COMMAND="$1" "$2"
    echo "============= TABLE $1 ============="
    echo "Current prepared command:"
    echo "$COMMAND"
    echo "1) Append"
    echo "2) Delete by rule specification"
    echo "3) Delete by position"
    echo "4) Insert to specified position"
    echo "5) Flush"
    echo "6) Zero"
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

selectChain ()
{
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    COMMAND="iptables -t $1"
    echo "========== TABLE $1 CHAIN =========="
    echo "Current prepared command:"
    echo "$COMMAND"
    echo "Select chain:"
    echo "1) OUTPUT"
    echo "2) INPUT"
    echo "3) FORWARD"
    echo "4) PREROUTING"
    echo "5) POSTROUTING"
    echo ""
    echo "0) Go back"
    
    while true
    do
      read -n 1 -p "Your choice: " MENUSELECTED
      echo ""
      echo ""
      case $MENUSELECTED in
        1 )
          addCommandToTableMenu "$COMMAND" "OUTPUT"
          break
          ;;
        2 )
          addCommandToTableMenu "$COMMAND" "INPUT"
          break
          ;;
        3 )
          addCommandToTableMenu "$COMMAND" "FORWARD"
          break
          ;;
        4 )
          addCommandToTableMenu "$COMMAND" "PREROUTING"
          break
          ;;
        5 )
          addCommandToTableMenu "$COMMAND" "POSTROUTING"
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
          selectChain "filter"
          break
          ;;
        2 )
          selectChain "nat"
          break
          ;;
        3 )
          selectChain "mangle"
          break
          ;;
        4 )
          selectChain "raw"
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

basicForAll ()
{
echo "
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# sudo iptables -A INPUT -m 
" >> "$CONFIG_FILE"
}

basicHomeFirewall ()
{
basicForAll

echo "
" >> "$CONFIG_FILE"

echo "DONE"
}

basicPublicFirewall ()
{
basicForAll

echo "
iptables -P INPUT DROP
# sudo iptables -P OUTPUT DROP

# sudo iptables -A 

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
  echo "Reading from file... ()"
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
    echo ""
    echo "8) Basic home firewall"
    echo "9) Basic public firewall"
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
          basicHomeFirewall
          break
          ;;
        9 )
          basicPublicFirewall
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