### The AUHPC Admins, Auburn University Office of Information Technology

# shell-for-hpc

Syntax, scripting, and automation patterns used frequently in high performance computing environments for reducing experimentation time, workflow repetition, and data processing overhead

[![AUHPC](https://img.youtube.com/vi/EkPCKVaJ68Q/0.jpg)](https://www.youtube.com/watch?v=EkPCKVaJ68Q" "AUHPC Event :: CLI Tools & Techniques")

## Common Research Use Cases

Native Linux CLI tools enable core research functions and accelerate experimentation:
‧ automation ‧ monitoring ‧ benchmarking ‧ optimization ‧  standardization ‧ data processing

### Metadata

Workflow metadata can be used to capture workflow properties, which are useful for organizing and identifying project components.

This is especially useful for logging and referential integrity across parametized experimental runs, and for standardizing and automating project tasks.

### Shell Essentials

#### Output Redirection

Linux shell environments provide a set of operators that can be used to change where command output is sent. By default, commands send output to the screen.

<details><summary>More on Descriptors</summary>
<p>

Most commands, but not all, will print the result of internal processes that complete succesfully as formatted text.

These messages are sent to a special file called a descriptor, which can be referenced with a reserved file system path or numeric identifier.

Unless explicitly specified commands will default to ``stdout`` for results and information or ``stderr`` for error messages.

stdin  : user or text input : 0 : /dev/stdin
stdout : error output       : 2 : /dev/stdout
stderr : error output       : 1 : /dev/stderr

Because each descriptor has its own associated path, they independently send and receive messages. As a result, it is important to note that `stderr` messages are typically not interpreted as input to redirect operators by default.
<p></details></br>

To change the behavior of a particular descriptor, the following shorthand patterns can be used:

```sh .command
ls 2>&1             # redirect all potential command output
ls >&1              # same as above, but a little shorter
ls >&2              # redirect all output as an error
ls 2>/dev/null      # silence error messages
ls 2>&1 >/dev/null  # silence all messages, no output
ls 1>/dev/null      # only print errors
```

The following operators can be used to redirect output from stderr and\or stdout for capturing output to file(s).

This is an essential pattern for HPC research, because it ensures that data persisted, and enables control over where results from experimental runs are stored in the filesystem.

```sh 
#append output to existing file (will create a file if it does not exist)
ls >> ~/files.txt | append to file

#write\create file (destructive)
ls >
```

#### Pipes

pipes send command output as input to another command:

```sh
whoami | id
```

Here we run the `whoami` command, which by itself prints your username to the screen. But, using a pipe `|` we feed that output into the `id` command which prints full account information.  You can chain pipes together to send output through many different commands.

#### Variables

variables allow you to store and reference values in a shell session or script:

```shell
greeting="hello"
subject="world"

echo "${greeting}, ${subject}!"
```

#### Inline Commands

Multiple commands can be run on the same shell prompt or script line by separating them with a semicolon, or you can break long command syntax into a more readable form with `\`:

```sh
whoami; id

echo "this prints a really long message to the screen, \
but might be easier to read if we break it into multiple lines."
```

While not most useful example, here we use the `echo` command to demonstrate splitting string input (in a shell strings are anythig enclosed in " " or ' ') into multiple lines.

A more useful example might be splitting a command that contains many parameters that are more easily parsed by breaking them into multiple lines:

```sh
command --with "many" \
--parameters "that contain" \
--values "that are" --more "readable" \
--when "broken up" \
--into "multiple lines"
```

<!-- #### Loops

Loops are a very useful construct that allow an operation to be performed on lists or arrays of data. There are numerous use cases for loops in HPC, especially for file and data processing.  A simple example to demonstrate this:

for number in "1 2 3 4 5"; do 
  echo "line ${number}" 
done -->

#### Subshells

The general syntax is: $(<command> <required_parameters> [optional_parameters])

```sh
clustername=$(hostname)
files=$(ls -1 ${HOME})
```

#### **Arrays**

Placeholder

#### **System Metadata**

Placeholder

#### **Time**

```sh 
man date
man -k date
man Date::Format

date +'%m%d%Y'
date +'%H%M%S'
```

#### **Downloading**

Use a public database or API to collect data directly from the cluster command line

```sh

# The Consumer Complaint Database is a public source for interesting data in various formats'
# It allows parameters to be passed with simple HTTP GET methods 

# https://www.consumerfinance.gov/data-research/consumer-complaints/search/api/v1/?format=csv&date_received_max=2023-04-01&date_received_min=2023-01-01
# https://www.consumerfinance.gov/data-research/consumer-complaints/search/api/v1/?limit=1000&format=csv&date_received_min=2023-03-01

datestamp=$(date +'%m%d%Y')
timestamp=$(date +'%H%M%S')

curl -o ./data/raw/complaints.${datestamp}.${timestamp}.csv https://www.consumerfinance.gov/data-research/consumer-complaints/search/api/v1/?format=csv&date_received_max=2023-01-01&date_received_min=2023-01-01

ls -al data/raw
wc -l ./data/raw/complaints.04062023.081145.csv

tail -1 ./data/raw/complaints.04062023.081145.csv
tail -10  ./data/raw/complaints.04062023.081145.csv | awk -F',' '{print $1}'
tail -10  data/raw/complaints.04062023.081145.csv | cut -d',' -f1
tail -10  data/raw/complaints.04062023.081145.csv | grep -ve "^[A-Za-z]" | cut -d',' -f1

awk -v FPAT='(".+")||([^,]+)||(^[ ]*$)'