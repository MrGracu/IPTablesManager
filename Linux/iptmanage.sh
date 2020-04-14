#!/bin/bash

addTablesMenu()
{
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    echo "============ ADD TO TABLE ============"
    echo "1) Add to FILTER table"
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

removeTablesMenu()
{
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    echo "========== REMOVE FROM TABLE ========="
    echo "1) Remove from FILTER table"
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

clearTablesMenu()
{
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    echo "============= CLEAR TABLE ============"
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

showTablesMenu()
{
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    echo "============= SHOW TABLES =============="
    echo "1) Show FILTER as table"
    echo "2) Show FILTER as specification"
    echo "3) Show NAT as table"
    echo "4) Show NAT as specification"
    echo "5) Show MANGLE as table"
    echo "6) Show MANGLE as specification"
    echo "7) Show RAW as table"
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
          sudo iptables -t filter -L -v
          break
          ;;
        2 )
          sudo iptables -t filter -S
          break
          ;;
        3 )
          sudo iptables -t nat -L -v
          break
          ;;
        4 )
          sudo iptables -t nat -S
          break
          ;;
        5 )
          sudo iptables -t mangle -L -v
          break
          ;;
        6 )
          sudo iptables -t mangle -S
          break
          ;;
        7 )
          sudo iptables -t raw -L -v
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

showMenu ()
{
  local CLOSE=false
  local MENUSELECTED
  while [[ "$CLOSE" == false ]]
  do
    echo "================= MENU ================="
    echo "1) Show all network interfaces"
    echo "2) Show specified table contents"
    echo "3) Add to specified table"
    echo "4) Remove from specified table"
    echo "5) Clear specified table"
    echo ""
    echo "0) Close program"
    
    while true
    do
      read -n 1 -p "Your choice: " MENUSELECTED
      echo ""
      echo ""
      case $MENUSELECTED in
        1 )
          ifconfig -a
          break
          ;;
        2 )
          showTablesMenu
          break
          ;;
        3 )
          addTablesMenu
          break
          ;;
        4 )
          removeTablesMenu
          break
          ;;
        5 )
          clearTablesMenu
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