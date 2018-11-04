#!/bin/bash
dotFile=$1

dot -Tpng $dotFile -o ${dotFile}.png
