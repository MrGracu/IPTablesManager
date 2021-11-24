#!/bin/bash

# +----------------------------------------------------------------------------------------------------+
# |  Copyright by Gracjan Mika ( https://gmika.pl ) and Patryk Potoczak ( https://github.com/toczak )  |
# |                                     IPTablesManage for Linux                                       |
# +----------------------------------------------------------------------------------------------------+

VERSION="0.7"

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

manualCommand ()
{
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    COMMAND="$1"
    echo "============ MANUAL COMMAND ============"
    echo "Type manually part of command"
    echo ""
    echo "0) Go back"
    
    while true
    do
      printf 'Write command: \e[0;32m%s\e[m ' "$COMMAND"
      read MENUSELECTED
      echo ""
      if [[ "$MENUSELECTED" =~ ^.{2,}$ ]]; then
        COMMAND="$COMMAND $MENUSELECTED"
        echo "ADDED"
        addParameters "$COMMAND" "$2" "$3" "$4"
        break
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

setParameterValue ()
{
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    COMMAND="$3"
    echo "============== $1 ==============" | tr a-z A-Z
    echo ""
    echo "0) Go back"
    
    while true
    do
      printf 'Add %s: \e[0;32m%s\e[m %s ' "$1" "$COMMAND" "$2"
      read MENUSELECTED
      echo ""
      if [[ "$MENUSELECTED" =~ ^.{2,}$ ]]; then
        COMMAND="$COMMAND $2 $MENUSELECTED"
        echo "ADDED"
        addParameters "$COMMAND" "$4" "$5" "$6"
        break
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

addValue ()
{
  local CANCEL=false
  local GOOD=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    GOOD=false
    if [[ "$5" == "icmp" || "$5" == "tcp" ]]; then
      COMMAND="$1 $5"
    else
      COMMAND="$1"
    fi
    echo "========= $5 OPTIONS =========" | tr a-z A-Z
    echo "Current prepared command:"
    echo -e '\E[32m'"$COMMAND"; tput sgr0
    echo "Select option:"
    local i=6
    while [ "$i" -le "$#" ]; do
      echo "$(($i-5))) ${!i}"
      let i++
    done
    echo ""
    echo "e) Add current command to file"
    echo "c) Continue with current command"
    echo ""
    echo "0) Go back"
    
    while true
    do
      if [ "$#" -le "13" ]; then
        read -n 1 -p "Your choice: " MENUSELECTED
        echo ""
      else
        read -p "Your choice: " MENUSELECTED
      fi
      echo ""
      if [[ "$MENUSELECTED" =~ ^[1-9][0-9]*$ ]]; then
        if [ "$MENUSELECTED" -le "$(($#-5))" ] && [ "$MENUSELECTED" -gt "0" ]; then
          if [[ "$5" == "LOG" && "$MENUSELECTED" == "1" ]]; then
            echo "Log levels:"
            echo "emergency (0)"
            echo "alert (1)"
            echo "critical (2)"
            echo "error (3)"
            echo "warning (4)"
            echo "notice (5)"
            echo "info (6)"
            echo "debug (7)"
          fi
          if [[ "$5" == "REJECT" && "$MENUSELECTED" == "1" ]]; then
            echo "Reject types:"
            echo "icmp-net-unreachable"
            echo "icmp-host-unreachable"
            echo "icmp-port-unreachable"
            echo "icmp-proto-unreachable"
            echo "icmp-net-prohibited"
            echo "icmp-host-prohibited"
            echo "icmp-admin-prohibited"
          fi
          if [[ "$5" == "TCPOPTSTRIP" && "$MENUSELECTED" == "1" ]]; then
            echo "Options:"
            echo "mss (2)"
            echo "wscale (3)"
            echo "sack-permitted (4)"
            echo "sack (5)"
            echo "timestamp (8)"
            echo "md5 (14)"
          fi
          if [[ "$5" == "tcp" && "$MENUSELECTED" == "1" ]]; then
            echo "TCP flags:"
            echo "SYN"
            echo "ACK"
            echo "FIN"
            echo "RST"
            echo "URG"
            echo "PSH"
            echo "ALL"
            echo "NONE"
          fi
          if [[ "$5" == "tcp" && "$MENUSELECTED" == "3" ]]; then
            echo "TCP options:"
            echo "1 - NO-OP, empty instruction"
            echo "2 - Maximum Segment Size"
            echo "3 - window scaling"
            echo "4 - consent to the use of SACK (Selective ACKnowledgment)"
            echo "5 - SACK option"
            echo "8 - time stamp"
            echo "14 - Alternative audit sum request (MD5)"
            echo "15 - alternative checksum"
          fi
          if [[ "$5" == "icmp" && "$MENUSELECTED" == "1" ]]; then
            echo "The most common ICMP types:"
            echo "any"
            echo "echo-reply"
            echo "destination-unreachable"
            echo "source-quench"
            echo "redirect"
            echo "echo-request"
            echo "router-advertisement"
            echo "router-solicitation"
            echo "time-exceeded"
            echo "parameter-problem"
            echo "timestamp-request"
            echo "timestamp-reply"
            echo "address-mask-request"
            echo "address-mask-reply"
          fi
          if [[ "$5" == "addrtype" && "$MENUSELECTED" == "1" ]] || [[ "$5" == "addrtype" && "$MENUSELECTED" == "2" ]]; then
            echo "Address types:"
            echo "UNSPEC"
            echo "UNICAST"
            echo "LOCAL"
            echo "BROADCAST"
            echo "ANYCAST"
            echo "MULTICAST"
            echo "XRESOLVE"
            echo "BLACKHOLE"
            echo "UNREACHABLE"
            echo "PROHIBIT"
            echo "THROW"
            echo "NAT"
          fi
          if [[ "$5" == "connbytes" && "$MENUSELECTED" == "1" ]]; then
            echo "Dir types:"
            echo "original"
            echo "reply"
            echo "both"
          fi
          if [[ "$5" == "connbytes" && "$MENUSELECTED" == "2" ]]; then
            echo "Dir types:"
            echo "packets"
            echo "bytes"
            echo "avgpkt"
          fi
          if [[ "$5" == "conntrack" && "$MENUSELECTED" == "1" ]]; then
            echo "States:"
            echo "INVALID"
            echo "NEW"
            echo "ESTABLISHED"
            echo "RELATED"
            echo "SNAT"
            echo "DNAT"
          fi
          if [[ "$5" == "conntrack" && "$MENUSELECTED" == "11" ]]; then
            echo "Statuses:"
            echo "NONE"
            echo "EXPECTED"
            echo "SEEN_REPLY"
            echo "ASSURED"
            echo "CONFIRMED"
          fi
          if [[ "$5" == "conntrack" && "$MENUSELECTED" == "13" ]]; then
            echo "Directories:"
            echo "ORIGINAL"
            echo "REPLY"
          fi
          if [[ "$5" == "pkttype" && "$MENUSELECTED" == "1" ]]; then
            echo "Types:"
            echo "unicast"
            echo "broadcast"
            echo "multicast"
          fi
          if [[ "$5" == "state" && "$MENUSELECTED" == "1" ]]; then
            echo "States:"
            echo "NEW"
            echo "ESTABLISHED"
            echo "RELATED"
            echo "INVALID"
          fi
          local VALUE
          let MENUSELECTED+=5
          echo "If value should be empty just press ENTER"
          printf 'Add value: \e[0;32m%s\e[m %s ' "$COMMAND" "${!MENUSELECTED}"
          read VALUE
          echo ""
          if [[ "$VALUE" == "" ]]; then
            COMMAND="$COMMAND ${!MENUSELECTED}"
          else
            COMMAND="$COMMAND ${!MENUSELECTED} $VALUE"
          fi
          echo "ADDED"
          addParameters "$COMMAND" "$2" "$3" "$4"
          break
        else
          echo "Bad option, try again"
        fi
      else
        if [[ "$MENUSELECTED" =~ ^0$ ]]; then
          CANCEL=true
          break
        else
          if [[ "$MENUSELECTED" =~ ^e$ ]]; then
            echo "$COMMAND" >> "$CONFIG_FILE"
            printf 'Added to file: \e[0;32m%s\e[m\n' "$COMMAND"
            CANCEL=true
            break
          else
            if [[ "$MENUSELECTED" =~ ^c$ ]]; then
              echo "CONTINUE"
              addParameters "$COMMAND" "$2" "$3" "$4"
              break
            else
              echo "Bad option, try again"
            fi
          fi
        fi
      fi
    done
  done
}

selectParamaterOption ()
{
  local CANCEL=false
  local MENUSELECTED
  local OPTIONS=""
  local i=1
  while [[ "$CANCEL" == false ]]
  do
    i=1
    COMMAND="$3 $2"
    echo "============== $1 ==============" | tr a-z A-Z
    echo "Current prepared command:"
    echo -e '\E[32m'"$COMMAND"; tput sgr0
    if [[ "$2" == "-p" ]]; then
      OPTIONS="tcp icmp udp udplite esp ah sctp all"
      for command in $OPTIONS; do
        echo "$i) $command"
        let i++
      done
    else
      if [[ "$2" == "-m" ]]; then
        OPTIONS="addrtype ah comment connbytes connlimit connmark conntrack helper iprange length mac mark multiport owner physdev pkttype quota recent state statistic tcpmss time ttl"
        for command in $OPTIONS; do
          echo "$i) $command"
          let i++
        done
      fi
    fi
    echo ""
    echo "e) Add current command to file"
    echo ""
    echo "0) Go back"
    
    while true
    do
      if [[ "$2" == "-p" ]]; then
        read -n 1 -p "Your choice: " MENUSELECTED
        echo ""
        echo ""
        case $MENUSELECTED in
          1 )
            addValue "$COMMAND" "$4" "$5" "$6" "tcp" "--tcp-flags" "--syn" "--tcp-option"
            break
            ;;
          2 )
            addValue "$COMMAND" "$4" "$5" "$6" "icmp" "--icmp-type"
            break
            ;;
          3 )
            COMMAND="$COMMAND udp"
            echo "ADDED"
            addParameters "$COMMAND" "$4" "$5" "$6"
            break
            ;;
          4 )
            COMMAND="$COMMAND udplite"
            echo "ADDED"
            addParameters "$COMMAND" "$4" "$5" "$6"
            break
            ;;
          5 )
            COMMAND="$COMMAND esp"
            echo "ADDED"
            addParameters "$COMMAND" "$4" "$5" "$6"
            break
            ;;
          6 )
            COMMAND="$COMMAND ah"
            echo "ADDED"
            addParameters "$COMMAND" "$4" "$5" "$6"
            break
            ;;
          7 )
            COMMAND="$COMMAND sctp"
            echo "ADDED"
            addParameters "$COMMAND" "$4" "$5" "$6"
            break
            ;;
          8 )
            COMMAND="$COMMAND all"
            echo "ADDED"
            addParameters "$COMMAND" "$4" "$5" "$6"
            break
            ;;
          e )
            echo "$COMMAND" >> "$CONFIG_FILE"
            printf 'Added to file: \e[0;32m%s\e[m\n' "$COMMAND"
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
      else
        if [[ "$2" == "-m" ]]; then
          read -p "Your choice: " MENUSELECTED
          echo ""
          if [[ "$MENUSELECTED" =~ ^[1-9][0-9]*$ ]]; then
            if [ "$MENUSELECTED" -le "$i" ] && [ "$MENUSELECTED" -gt "0" ]; then
              local j=1
              for command in $OPTIONS; do
                if [ "$j" -eq "$MENUSELECTED" ]; then
                  if [[ "$command" == "addrtype" ]]; then
                    addValue "$COMMAND" "$4" "$5" "$6" "$command" "--src-type" "--dst-type" "--limit-iface-in" "--limit-iface-out"
                  else
                    if [[ "$command" == "ah" ]]; then
                      addValue "$COMMAND" "$4" "$5" "$6" "$command" "--ahspi"
                    else
                      if [[ "$command" == "comment" ]]; then
                        addValue "$COMMAND" "$4" "$5" "$6" "$command" "--comment"
                      else
                        if [[ "$command" == "connbytes" ]]; then
                          addValue "$COMMAND" "$4" "$5" "$6" "$command" "--connbytes-dir" "--connbytes-mode" "--connbytes"
                        else
                          if [[ "$command" == "connlimit" ]]; then
                            addValue "$COMMAND" "$4" "$5" "$6" "$command" "--connlimit-upto" "--connlimit-above" "--connlimit-mask" "--connlimit-saddr" "--connlimit-daddr"
                          else
                            if [[ "$command" == "connmark" ]]; then
                              addValue "$COMMAND" "$4" "$5" "$6" "$command" "--mark"
                            else
                              if [[ "$command" == "conntrack" ]]; then
                                addValue "$COMMAND" "$4" "$5" "$6" "$command" "--ctstate" "--ctproto" "--ctorigsrc" "--ctorigdst" "--ctreplsrc" "--ctrepldst" "--ctorigsrcport" "--ctorigdstport" "--ctreplsrcport" "--ctrepldstport" "--ctstatus" "--ctexpire" "--ctdir"
                              else
                                if [[ "$command" == "helper" ]]; then
                                  addValue "$COMMAND" "$4" "$5" "$6" "$command" "--helper"
                                else
                                  if [[ "$command" == "iprange" ]]; then
                                    addValue "$COMMAND" "$4" "$5" "$6" "$command" "--src-range" "--dst-range"
                                  else
                                    if [[ "$command" == "length" ]]; then
                                      addValue "$COMMAND" "$4" "$5" "$6" "$command" "--length"
                                    else
                                      if [[ "$command" == "mac" ]]; then
                                        addValue "$COMMAND" "$4" "$5" "$6" "$command" "--mac-source"
                                      else
                                        if [[ "$command" == "mark" ]]; then
                                          addValue "$COMMAND" "$4" "$5" "$6" "$command" "--mark"
                                        else
                                          if [[ "$command" == "multiport" ]]; then
                                            addValue "$COMMAND" "$4" "$5" "$6" "$command" "--source-ports" "--destination-ports" "--ports"
                                          else
                                            if [[ "$command" == "owner" ]]; then
                                              addValue "$COMMAND" "$4" "$5" "$6" "$command" "--uid-owner" "--gid-owner" "--socket-exists"
                                            else
                                              if [[ "$command" == "physdev" ]]; then
                                                addValue "$COMMAND" "$4" "$5" "$6" "$command" "--physdev-in" "--physdev-out" "--physdev-is-in" "--physdev-is-out" "--physdev-is-bridged"
                                              else
                                                if [[ "$command" == "pkttype" ]]; then
                                                  addValue "$COMMAND" "$4" "$5" "$6" "$command" "--pkt-type"
                                                else
                                                  if [[ "$command" == "quota" ]]; then
                                                    addValue "$COMMAND" "$4" "$5" "$6" "$command" "--quota"
                                                  else
                                                    if [[ "$command" == "recent" ]]; then
                                                      addValue "$COMMAND" "$4" "$5" "$6" "$command" "--name" "--rdest" "--rsource" "--set" "--rcheck" "--remove" "--update" "--seconds" "--hitcount" "--rttl"
                                                    else
                                                      if [[ "$command" == "state" ]]; then
                                                        addValue "$COMMAND" "$4" "$5" "$6" "$command" "--state"
                                                      else
                                                        if [[ "$command" == "statistic" ]]; then
                                                          addValue "$COMMAND" "$4" "$5" "$6" "$command" "--mode" "--probability" "--every" "--packet"
                                                        else
                                                          if [[ "$command" == "tcpmss" ]]; then
                                                            addValue "$COMMAND" "$4" "$5" "$6" "$command" "--mss"
                                                          else
                                                            if [[ "$command" == "time" ]]; then
                                                              addValue "$COMMAND" "$4" "$5" "$6" "$command" "--datestart" "--datestop" "--timestart" "--timestop" "--monthdays" "--weekdays" "--utc" "--localtz"
                                                            else
                                                              if [[ "$command" == "ttl" ]]; then
                                                                addValue "$COMMAND" "$4" "$5" "$6" "$command" "--ttl-eq" "--ttl-lt" "--ttl-gt"
                                                              else
                                                                COMMAND="$COMMAND $command"
                                                                echo "ADDED"
                                                                addParameters "$COMMAND" "$4" "$5" "$6"
                                                              fi
                                                            fi
                                                          fi
                                                        fi
                                                      fi
                                                    fi
                                                  fi
                                                fi
                                              fi
                                            fi
                                          fi
                                        fi
                                      fi
                                    fi
                                  fi
                                fi
                              fi
                            fi
                          fi
                        fi
                      fi
                    fi
                  fi
                  break
                fi
                let j++
              done
              break
            else
              echo "Bad option, try again"
            fi
          else
            if [[ "$MENUSELECTED" =~ ^0$ ]]; then
              CANCEL=true
              break
            else
              if [[ "$MENUSELECTED" =~ ^e$ ]]; then
                echo "$COMMAND" >> "$CONFIG_FILE"
                printf 'Added to file: \e[0;32m%s\e[m\n' "$COMMAND"
                CANCEL=true
                break
              else
                echo "Bad option, try again"
              fi
            fi
          fi
        fi
      fi
    done
  done
}

addParameters ()
{
  local CANCEL=false
  local MENUSELECTED
  while [[ "$CANCEL" == false ]]
  do
    COMMAND="$1"
    echo "============== PARAMETERS =============="
    echo "Current prepared command:"
    echo -e '\E[32m'"$COMMAND"; tput sgr0
    echo "1) -j (jump/action)"
    echo "2) -s (source)"
    echo "3) -d (destination)"
    echo "4) -i (in-interface)"
    echo "5) -o (out-interface)"
    echo "6) -p (protocol)"
    echo "7) -m (match)"
    echo "8) --sport (source-port)"
    echo "9) --dport (destination-port)"
    echo ""
    echo "m) Add manually paramater to command"
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
          setAction "$COMMAND" "$2" "$3" "$4"
          break
          ;;
        2 )
          setParameterValue "source" "-s" "$COMMAND" "$2" "$3" "$4"
          break
          ;;
        3 )
          setParameterValue "destination" "-d" "$COMMAND" "$2" "$3" "$4"
          break
          ;;
        4 )
          setParameterValue "in-interface" "-i" "$COMMAND" "$2" "$3" "$4"
          break
          ;;
        5 )
          setParameterValue "out-interface" "-o" "$COMMAND" "$2" "$3" "$4"
          break
          ;;
        6 )
          selectParamaterOption "protocol" "-p" "$COMMAND" "$2" "$3" "$4"
          break
          ;;
        7 )
          selectParamaterOption "match" "-m" "$COMMAND" "$2" "$3" "$4"
          break
          ;;
        8 )
          setParameterValue "source-port" "--sport" "$COMMAND" "$2" "$3" "$4"
          break
          ;;
        9 )
          setParameterValue "destination-port" "--dport" "$COMMAND" "$2" "$3" "$4"
          break
          ;;
        m )
          manualCommand "$COMMAND" "$2" "$3" "$4"
          break
          ;;
        e )
          echo "$COMMAND" >> "$CONFIG_FILE"
          printf 'Added to file: \e[0;32m%s\e[m\n' "$COMMAND"
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
  done
}

setAction ()
{
  local CANCEL=false
  local MENUSELECTED
  local GOOD=false
  local ACTION=""
  while [[ "$CANCEL" == false ]]
  do
    GOOD=false
    COMMAND="$1"
    echo "============== SET ACTION =============="
    echo "Current prepared command:"
    echo -e '\E[32m'"$COMMAND"; tput sgr0
    echo "1) ACCEPT"
    if [[ "$2" == "mangle" ]]; then echo "2) CLASSIFY"; fi
    echo "3) CONNMARK"
    if [[ "$2" == "nat" ]] && ([[ "$4" == "PREROUTING" || "$4" == "OUTPUT" ]]); then echo "4) DNAT"; fi
    if [[ "$2" == "filter" ]]; then echo "5) DROP"; fi
    if [[ "$2" == "mangle" ]]; then echo "6) DSCP"; fi
    echo "7) LOG"
    if [[ "$2" == "mangle" ]]; then echo "8) MARK"; fi
    if [[ "$2" == "nat" ]] && [[ "$4" == "POSTROUTING" ]]; then echo "9) MASQUERADE"; fi
    if [[ "$2" == "nat" ]]; then echo "10) NETMAP"; fi
    if [[ "$2" == "raw" ]]; then echo "11) NOTRACK"; fi
    if [[ "$2" == "nat" ]] && ([[ "$4" == "PREROUTING" || "$4" == "OUTPUT" ]]); then echo "12) REDIRECT"; fi
    if [[ "$2" == "filter" ]]; then echo "13) REJECT"; fi
    if [[ "$2" == "nat" ]] && [[ "$4" == "POSTROUTING" ]]; then echo "14) SNAT"; fi
    if [[ "$2" == "filter" ]] && ([[ "$4" == "INPUT" || "$4" == "FORWARD" ]]); then echo "15) TARPIT"; fi
    if [[ "$2" == "mangle" ]]; then echo "16) TCPOPTSTRIP"; fi
    if [[ "$2" == "mangle" ]] && [[ "$4" == "PREROUTING" ]]; then echo "17) TPROXY"; fi
    if [[ "$2" == "mangle" ]]; then echo "18) TTL"; fi
    echo ""
    echo "e) Add current command to file"
    echo ""
    echo "0) Go back"
    
    while true
    do
      read -p "Your choice: " MENUSELECTED
      echo ""
      echo ""
      case $MENUSELECTED in
        1 )
          ACTION="ACCEPT"
          GOOD=true
          break
          ;;
        2 )
          if [[ "$2" == "mangle" ]]; then 
            ACTION="CLASSIFY"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        3 )
          ACTION="CONNMARK"
          GOOD=true
          break
          ;;
        4 )
          if [[ "$2" == "nat" ]] && ([[ "$4" == "PREROUTING" || "$4" == "OUTPUT" ]]); then 
            ACTION="DNAT"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        5 )
          if [[ "$2" == "filter" ]]; then 
            ACTION="DROP"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        6 )
          if [[ "$2" == "mangle" ]]; then 
            ACTION="DSCP"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        7 )
          ACTION="LOG"
          GOOD=true
          break
          ;;
        8 )
          if [[ "$2" == "mangle" ]]; then 
            ACTION="MARK"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        9 )
          if [[ "$2" == "nat" ]]; then 
            ACTION="MASQUERADE"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        10 )
          if [[ "$2" == "nat" ]]; then 
            ACTION="NETMAP"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        11 )
          if [[ "$2" == "raw" ]]; then 
            ACTION="NOTRACK"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        12 )
          if [[ "$2" == "nat" ]] && ([[ "$4" == "PREROUTING" || "$4" == "OUTPUT" ]]); then 
            ACTION="REDIRECT"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        13 )
          if [[ "$2" == "filter" ]]; then 
            ACTION="REJECT"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        14 )
          if [[ "$2" == "nat" ]] && [[ "$4" == "POSTROUTING" ]]; then 
            ACTION="SNAT"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        15 )
          if [[ "$2" == "filter" ]] && ([[ "$4" == "INPUT" || "$4" == "FORWARD" ]]); then 
            ACTION="TARPIT"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        16 )
          if [[ "$2" == "mangle" ]]; then 
            ACTION="TCPOPTSTRIP"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        17 )
          if [[ "$2" == "mangle" ]] && [[ "$4" == "PREROUTING" ]]; then 
            ACTION="TPROXY"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        18 )
          if [[ "$2" == "mangle" ]]; then 
            ACTION="TTL"
            GOOD=true
            break
          else
            echo "Bad option, try again"
          fi
          ;;
        e )
          echo "$COMMAND" >> "$CONFIG_FILE"
          printf 'Added to file: \e[0;32m%s\e[m\n' "$COMMAND"
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
      if [[ "$3" == "-P" ]]; then
        local SURE
        COMMAND="$COMMAND $ACTION"
        echo -e '\E[32m'"$COMMAND"; tput sgr0
        read -p "Add this command to file? [y/n] " SURE
        echo ""
        if [[ "$SURE" =~ ^y$ ]]; then
          echo "$COMMAND" >> "$CONFIG_FILE"
          printf 'Added to file: \e[0;32m%s\e[m\n' "$COMMAND"
          CANCEL=true
        else
          echo "Operation canceled"
        fi
      else
        COMMAND="$COMMAND -j $ACTION"
        if [[ "$ACTION" == "CLASSIFY" ]]; then
          addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--set-class"
        else
          if [[ "$ACTION" == "CONNMARK" ]]; then
            if [[ "$2" == "mangle" ]]; then
              addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--set-xmark" "--save-mark" "--restore-mark" "--and-mark" "--or-mark" "--set-mark"
            else
              addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--set-xmark" "--save-mark" "--and-mark" "--or-mark" "--set-mark"
            fi
          else
            if [[ "$ACTION" == "DNAT" ]]; then
              addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--to-destination" "--random" "--persistent"
            else
              if [[ "$ACTION" == "DSCP" ]]; then
                addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--set-dscp" "--set-dscp-class"
              else
                if [[ "$ACTION" == "LOG" ]]; then
                  addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--log-level" "--log-prefix" "--log-tcp-sequence" "--log-tcp-options" "--log-ip-options" "--log-uid"
                else
                  if [[ "$ACTION" == "MARK" ]]; then
                    addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--set-xmark" "--set-mark" "--and-mark" "--or-mark" "--xor-mark"
                  else
                    if [[ "$ACTION" == "MASQUERADE" ]]; then
                      addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--to-ports" "--random"
                    else
                      if [[ "$ACTION" == "NETMAP" ]]; then
                        addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--to"
                      else
                        if [[ "$ACTION" == "REDIRECT" ]]; then
                          addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--to-ports" "--random"
                        else
                          if [[ "$ACTION" == "REJECT" ]]; then
                            addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--reject-with"
                          else
                            if [[ "$ACTION" == "SNAT" ]]; then
                              addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--to-source" "--random" "--persistent"
                            else
                              if [[ "$ACTION" == "TCPOPTSTRIP" ]]; then
                                addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--strip-options"
                              else
                                if [[ "$ACTION" == "TPROXY" ]]; then
                                  addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--on-port" "--tproxy-mark"
                                else
                                  if [[ "$ACTION" == "TPROXY" ]]; then
                                    addValue "$COMMAND" "$2" "$3" "$4" "$ACTION" "--ttl-set" "--ttl-dec" "--ttl-inc"
                                  else
                                    addParameters "$COMMAND" "$2" "$3" "$4"
                                  fi
                                fi
                              fi
                            fi
                          fi
                        fi
                      fi
                    fi
                  fi
                fi
              fi
            fi
          fi
        fi
      fi
    fi
  done
}

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
    echo -e '\E[32m'"$COMMAND"; tput sgr0
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
          printf 'Added to file: \e[0;32m%s\e[m\n' "$COMMAND"
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
        echo -e '\E[32m'"$COMMAND"; tput sgr0
        read -p "Add this command to file? [y/n] " SURE
        echo ""
        if [[ "$SURE" =~ ^y$ ]]; then
          echo "$COMMAND" >> "$CONFIG_FILE"
          printf 'Added to file: \e[0;32m%s\e[m\n' "$COMMAND"
          CANCEL=true
        else
          echo "Operation canceled"
        fi
      else
        if [[ "$2" == "-P" ]]; then
          setAction "$COMMAND" "$1" "$2" "CHAINSELECTED"
        else
          addParameters "$COMMAND" "$1" "$2" "$CHAINSELECTED"
        fi
      fi
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
    echo "============ TABLE $1 ============"
    echo "Current prepared command:"
    echo -e '\E[32m'"$COMMAND"; tput sgr0
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
          if [[ "$POSITION" =~ ^[1-9][0-9]*$ ]]; then
            selectChain "$1" "-D" "$POSITION"
            break
          else
            echo "Bad position NUMBER"
          fi
          ;;
        4 )
          read -p "Position of rule to insert: " POSITION
          if [[ "$POSITION" =~ ^[1-9][0-9]*$ ]]; then
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
iptables -A OUTPUT -o lo -j ACCEPT

iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP  # NULL PACKETS
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP   # SYN-FLOOD ATTACK
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP   # XMAS PACKETS

# iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT   # HTTP
# iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT  # HTTPS
# iptables -A INPUT -p tcp -m tcp --dport 5900 -j ACCEPT # VNC 1

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

clearIpconfig ()
{
  local SURE
  echo "======== CLEAR IPTABLES CONFIG ========="
  echo "You want to clear current iptables config"
  read -p "Are you sure? [y/n] " SURE
  if [[ ! "$SURE" =~ ^y$ ]]; then
    echo "Operation canceled"
    return
  fi
  sudo iptables -P INPUT ACCEPT
  sudo iptables -P FORWARD ACCEPT
  sudo iptables -P OUTPUT ACCEPT
  sudo iptables -t nat -F
  sudo iptables -t mangle -F
  sudo iptables -F
  sudo iptables -X
  sudo iptables -L
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

about ()
{
  echo "+----------------------------------------+"
  echo "|                                        |"
  echo "|            IPTablesManager             |"
  echo "|              VERSION: $VERSION              |"
  echo "|                                        |"
  echo "+----------------------------------------+"
}

showMenu ()
{
  local CLOSE=false
  local MENUSELECTED
  while [[ "$CLOSE" == false ]]
  do
    echo "================= MENU ================="
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
    echo "9) Add basic firewall to file"
    echo ""
    echo "i) Show all network interfaces"
    echo "c) Clear current iptables config"
    echo "a) About this program"
    echo ""
    echo "0) Close program"
    
    while true
    do
      read -n 1 -p "Your choice: " MENUSELECTED
      echo ""
      echo ""
      case $MENUSELECTED in
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
        i )
          ifconfig -a || ip address show
          break
          ;;
		c )
          clearIpconfig
          break
          ;;
        a )
          about
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