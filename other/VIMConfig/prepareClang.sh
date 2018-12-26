#!/bin/bash
ThisScript=$0
InputPath=$1
OutputPath=$2

if [ "$InputPath" == "" ]; then
    InputPath=$PWD
    echo "Input Path is $InputPath"
fi
if [ "$OutputPath" == "" ]; then
    OutputPath=$PWD
    echo "Output Path is $OutputPath"
fi

# handle local project
find $InputPath -type f -name "*.h" -o -name "*.hpp" | sed -r 's|/[^/]+$||' | sort | uniq | awk '{printf "-I%s\n", $1}' > $OutputPath/.clang_complete

# handle third party project
echo "-I/usr/local/boost/1.59.0/include" >> $OutputPath/.clang_complete

echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include" >> $OutputPath/.clang_complete
find "/usr/local/Qt/5.6.2/5.6/gcc_64/include" -type f -name "*.h" -o -name "*.hpp" | sed -r 's|/[^/]+$||' | sort | uniq | awk '{printf "-I%s\n", $1}' >> $OutputPath/.clang_complete

echo "-I/usr/local/json-c/master/include/json-c" >> $OutputPath/.clang_complete

echo "-I/usr/local/jwt-cpp/include" >> $OutputPath/.clang_complete

echo "-I/usr/local/openssl/1.1/include" >> $OutputPath/.clang_complete

echo "-I/usr/local/libxml2/2.9.8/include/libxml2" >> $OutputPath/.clang_complete

echo "-I/usr/local/libpng/1.6.35/include" >> $OutputPath/.clang_complete

echo "-I/usr/local/libcurl/7.63.0/include" >> $OutputPath/.clang_complete

echo "-I/usr/local/libdash/master/include" >> $OutputPath/.clang_complete

find "/usr/include/c++/5" -type f -name "*.h" -o -name "*.hpp" | sed -r 's|/[^/]+$||' | sort | uniq | awk '{printf "-I%s\n", $1}' >> $OutputPath/.clang_complete
