#!/usr/bin/env bash
list(){
    echo "---- command list: ----"
    for entry in ./cmds/*
    do
        if [[ $entry != "./cmds/errors" ]]; then 
            echo "$entry" | awk -F '/' '{print $3}'
        fi
    done

    echo "---- HELP: ----"
    echo "to execute:"$0" command-list.txt"
    echo "for help: $0 usage [command]"
}

get_token(){
    # token check
    if [[ -z "$token" ]]; then
        if [ ! -e ".token" ]; then
            echo ".token file not found!"
            exit 2
        fi
        token=$(head -n 1 .token)
        if [[ -z "$token" ]]; then
            echo "please provide a valid .token file!"
            exit 2
        fi
    fi
}

printf "============\nOrderCloud CLI\n============\nReading command list from $1\n"

# if usage command
if [[ ! -z "$1" ]] && [ $1 == "usage" ]; then
    list
    if [[ ! -z "$2" ]]; then
        CMD=cmds/"$2"
        var=$(sh $CMD "usage")
        echo "------ COMMAND USAGE:"$'\n'"$var"
    fi
    exit 0
fi

# if command file does not exist
if [ ! -e "$1" ]; then
    printf $1" file not found!\ntype $0 usage\n"
    exit 1
fi

# host check
read -r -a line<.credentials;host=${line[0]}
if [ ! -e ".credentials" ]; then
    echo ".credentials file not found!"
    exit 3
fi

echo "Working with host: "$host

while read -r -a command 
do 
    
    if [[ ${command[0]} == "--" && ${command[1]} == "END" ]]; then 
        echo "<--"
        exit 0
    fi
    if [[ ${command[0]} == "--" && ${command[1]} == "START" ]]; then 
        START=1
        echo "--> executing..."
        continue
    fi

    if [[ $START == 1 && ! -z "${command[0]}" ]]; then
        CMD=$PWD/cmds/"${command[0]}"
        # checks if CMD does not exists
        if [ ! -e "$CMD" ]; then
            echo $CMD" command not found!"
            exit 3
        fi
        if [ ${command[0]} == "login" ]; then
            result=$(sh $CMD ${line[@]} ${command[@]:1})
            read -d : -a var <<< "$result";
            if [[ ${var[0]} -eq 200 ]]; then
                cut -d \" -f 4 logs/login.log > .token
            fi
        else
            get_token
            result=$(sh $CMD $host $token ${command[@]:1})
            if [[ ${command[0]} == "buyer" && ${command[1]} == "impersonate" ]]; then
                read -d : -a var <<< "$result";
                if [[ ${var[0]} -eq 200 ]]; then
                    cp .token .token.back
                    cut -d \" -f 4 logs/buyer.impersonate.log > .token
                fi
            fi
        fi
        
        echo ${command[@]}:"$result"
        RC=$?
        read -d : -a var <<< "$result";
        if [[ ${var[0]} -gt 399 ]]; then
            if [[ $RC -eq 255 ]]; then
                printf "<--\n$CMD command usage:\n ${var[0]}\n"
            else    
                printf "<--\n${command[@]} exits with error: ${var[0]}\n"
            fi   
            exit 1
        fi
    fi
done < $1
