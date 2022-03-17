# Sitecore OrderCloud CLI
OrderCloud CLI for buyers. It is intended to be used by buyers to create and submit orders.

## Tested with
- Sitecore OrderCloud Sandbox
- MacOS
- it should work with Linux and Windows+cygwin (I never tested)

## Start
- create a file named `.credentials` by using the `.credentials_template` file. The format is simple: one line with OC endpoint, clientid and buyer credentials (without password it tries to login as anonymous if API client is configured accordingly).
- populate the `command-list.txt` file (there is one in the `/examples` folder)
    - the file contains the list of commands you want to execute on the OC tenant
    - the script exits upon the first error
- execute the shell script
    ```bash
    ./oc-cli.sh examples/command-list.txt
    ```
- read the output and look in the `logs` folder. Each command has its own log file.

To retrieve the list of implemented commands type `./oc-cli.sh usage`.

To retrive the specific command usage type `./oc-cli.sh usage [order|line|login|...]`, an example in the following:

```bash
> ./oc-cli.sh usage order
============
OrderCloud CLI
============
Reading command list from usage
---- command list: ----
line
login
order
---- HELP: ----
to execute:./oc-cli.sh command-list.txt
for help: ./oc-cli.sh usage [command]
------ COMMAND USAGE:
    order (usage|host) [token] [get|create|calculate|estimateshipping|shipmethods|submit] [params]
    examples for oc-cli command list file:
        order create order_123.json
        order calculate O_123
        order submit 0_123
        order get 0_123
```

## Command List (currently)
- login
    - it requires the file `.credentials``
- order
- line

## Examples
```bash
./oc-cli.sh command-list.txt
```
where the command file contains:

```
-- START
login
order create order.json
line add TEST1056 addline.json
line add TEST1056 addline2.json
order calculate TEST1056
order submit TEST1056
order get TEST1056
-- END
```

While the files order.json and addline*.json contains the JSON needed to populate the entity. You can create as many as you need, pls use the ID in order to update the order in the right way (eg. order.json in this example as the ID:"TEST1056"). Examples are provided in this repo.

## Command List File
```
NOT EXECUTED LINE ....
-- START
order create order.json
line add TEST1056 addline.json
line add TEST1056 addline2.json
order calculate TEST1056
order submit TEST1056
order get TEST1056
-- END
NOT EXECUTED LINE
```
The CLI executes only the lines between the `-- START` and `-- END`. During the execution a command in the list could fail, in this case the cli stops. To recover the execution from the place it stopped, move the `-- START` and the `-- END` lines in order to include the commands you want to retry.

## Login
the login script reads from `.credentials` file and stores the token in a file named `.token`. 
This file will be used by other command scripts.
## Logs
Each command execution generates a log file in the logs folder.
## Report
The oc-cli executes and writes the output line by line as defined in the command file.
Each row reports http_status_code and elapsed in seconds.
```
============
OrderCloud CLI
============
Reading command list from command-list.txt
Working with host: your-endpoint.ordercloud.io
--> executing...
order create order.json:201:0.297448s
line add TEST1057 addline.json:201:4.270156s
line add TEST1057 addline2.json:201:0.986618s
order calculate TEST1057:201:3.829835s
order submit TEST1057:201:0.293340s
order get TEST1057:200:0.177165s
<--
```


## How To Contribute
You can add scripts in the cmds folder by using your own scripting language (bash, ruby, ...)

- write your own script 
  - has to accept at least 1 parameter: `usage`
  - can accept more parameters to use in the script
  - finally, print a string to be used as Report
- save your script in the folder cmds
- add a usage example in the Examples section
- return http_status_code:elapsed

# Limitations and Disclaimer
THE SOFTWARE IS PROVIDED “AS IS.” YOU BEAR THE RISK OF USING IT. PLEASE USE IT IN NON PRODUCTION ENVIRONMENTS.
