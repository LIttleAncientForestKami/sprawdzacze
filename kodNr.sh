#!/bin/bash
# @LAFK_pl
# Simple code number crunching
echo Code lines
find . -name \*.java -exec wc -l {} \; | sort -n > lines
awk '{total+=$1}END{print "Total: " total}' < lines
grep ./src/main lines | awk '{total+=$1}END{print "src/main: "total}'
grep ./client lines | awk '{total+=$1}END{print "Client: "total}'
grep ./client lines | grep src/main | awk '{total+=$1}END{print "Client main: "total}'
grep ./server lines | awk '{total+=$1}END{print "Server: "total}'
grep ./server lines | grep src/main | awk '{total+=$1}END{print "Server main: "total}'
egrep ./common\|./utils\|./shared\|./infra lines | awk '{total+=$1}END{print "Shared: "total}'
egrep ./common\|./utils\|./shared\|./infra lines | grep src/main | awk '{total+=$1}END{print "Shared (src/main): "total}'

echo Java files not in src/test: $(find */src/main/ -name \*.java | wc -l)
echo Java files IN src/test $(find */src/test/ -name \*.java | wc -l)

grep -v /src/test/ lines > nonTest
echo Client / Server / Other  $(grep -c ./client/ nonTest) $(grep -c ./server/ nonTest) $(grep -v ./server/ nonTest | grep -v ./client/ | wc -l)

echo "#files package"
find . -name \*.java -exec grep package {} \; | cut -d : -f 2 | cut -d " " -f 2 | tr -d ';' | sort | uniq -c
echo Number of packages: $(find . -name \*.java -exec grep package {} \; | cut -d : -f 2 | cut -d " " -f 2 | tr -d ';' | sort | uniq -c | wc -l)

echo Interfaces
find */src/main -name \*.java -exec grep interface {} \; | grep -v "*"
echo Nr of interfaces: $(find */src/main -name \*.java -exec grep interface {} \; | grep -v "*" | wc -l)
